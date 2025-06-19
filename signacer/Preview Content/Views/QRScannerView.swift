import SwiftUI
import AVFoundation

struct QRScannerView: UIViewRepresentable {
    typealias UIViewType = ScannerUIView
    var completion: (Result<String, QRScanError>) -> Void
    
    func makeUIView(context: Context) -> ScannerUIView {
        let view = ScannerUIView()
        view.completion = completion
        return view
    }
    
    func updateUIView(_ uiView: ScannerUIView, context: Context) {
        // No update needed
    }
}

enum QRScanError: Error, LocalizedError {
    case cameraUnavailable
    case cameraAccessDenied
    case invalidQRCode
    case scanningFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera is not available"
        case .cameraAccessDenied:
            return "Camera access denied. Please enable camera access in Settings."
        case .invalidQRCode:
            return "Unknown QR Code"
        case .scanningFailed:
            return "QR code scanning failed"
        case .unknown(let message):
            return message
        }
    }
}

class ScannerUIView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var completion: ((Result<String, QRScanError>) -> Void)?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var scannerOverlayView: UIView?
    private var animationTimer: Timer?
    private var isAnimatingUp = false
    private var hasScanned = false // Prevent multiple scans
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }
    
    func setupSession() {
        // Check camera permission first
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureCamera()
                    } else {
                        self?.completion?(.failure(.cameraAccessDenied))
                    }
                }
            }
        case .denied, .restricted:
            completion?(.failure(.cameraAccessDenied))
        @unknown default:
            completion?(.failure(.cameraUnavailable))
        }
    }
    
    private func configureCamera() {
        guard !hasScanned else { return }
        
        do {
            captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                completion?(.failure(.cameraUnavailable))
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            guard let captureSession = captureSession else {
                completion?(.failure(.cameraUnavailable))
                return
            }
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                completion?(.failure(.cameraUnavailable))
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr, .code128, .code39, .ean8, .ean13, .pdf417]
            } else {
                completion?(.failure(.cameraUnavailable))
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.frame = self.layer.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            
            if let previewLayer = previewLayer {
                self.layer.addSublayer(previewLayer)
            }
            
            setupOverlay()
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
            
        } catch {
            completion?(.failure(.cameraUnavailable))
        }
    }
    
    func setupOverlay() {
        // Add dimmed background with clear scanning area
        let overlayView = UIView(frame: bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Calculate scanner frame - a square that's 50% of the smaller dimension
        let minDimension = min(bounds.width, bounds.height)
        let scannerSize = minDimension * 0.5
        let scannerOriginX = (bounds.width - scannerSize) / 2
        let scannerOriginY = (bounds.height - scannerSize) / 2
        let scannerFrame = CGRect(x: scannerOriginX, y: scannerOriginY, width: scannerSize, height: scannerSize)
        
        // Create scanner window (transparent cutout)
        let path = UIBezierPath(rect: bounds)
        let scannerPath = UIBezierPath(roundedRect: scannerFrame, cornerRadius: 20)
        path.append(scannerPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // Add corner brackets
        let cornerLength = scannerSize * 0.1
        let lineWidth: CGFloat = 5
        let cornerColor = UIColor.white.cgColor
        
        // Top left corner
        let topLeftCorner = createCorner(at: CGPoint(x: scannerFrame.minX, y: scannerFrame.minY),
                                        isHorizontal: true, isVertical: true,
                                        length: cornerLength, lineWidth: lineWidth, color: cornerColor)
        
        // Top right corner
        let topRightCorner = createCorner(at: CGPoint(x: scannerFrame.maxX, y: scannerFrame.minY),
                                         isHorizontal: false, isVertical: true,
                                         length: cornerLength, lineWidth: lineWidth, color: cornerColor)
        
        // Bottom left corner
        let bottomLeftCorner = createCorner(at: CGPoint(x: scannerFrame.minX, y: scannerFrame.maxY),
                                          isHorizontal: true, isVertical: false,
                                          length: cornerLength, lineWidth: lineWidth, color: cornerColor)
        
        // Bottom right corner
        let bottomRightCorner = createCorner(at: CGPoint(x: scannerFrame.maxX, y: scannerFrame.maxY),
                                           isHorizontal: false, isVertical: false,
                                           length: cornerLength, lineWidth: lineWidth, color: cornerColor)
        
        let cornersView = UIView(frame: bounds)
        cornersView.layer.addSublayer(topLeftCorner)
        cornersView.layer.addSublayer(topRightCorner)
        cornersView.layer.addSublayer(bottomLeftCorner)
        cornersView.layer.addSublayer(bottomRightCorner)
        
        addSubview(overlayView)
        addSubview(cornersView)
        
        self.scannerOverlayView = overlayView
    }
    
    func createCorner(at point: CGPoint, isHorizontal: Bool, isVertical: Bool, length: CGFloat, lineWidth: CGFloat, color: CGColor) -> CAShapeLayer {
        let corner = CAShapeLayer()
        corner.strokeColor = color
        corner.lineWidth = lineWidth
        corner.lineCap = .round
        corner.fillColor = UIColor.clear.cgColor
        
        let path = UIBezierPath()
        let radius: CGFloat = 8 // Corner radius for the brackets
        
        // Calculate the offset from the corner point
        let offsetX: CGFloat = isHorizontal ? radius : -radius
        let offsetY: CGFloat = isVertical ? radius : -radius
        
        // Start point for horizontal line (offset from corner)
        let horizontalStart = CGPoint(x: point.x + offsetX, y: point.y)
        let horizontalEnd = CGPoint(x: point.x + (isHorizontal ? length : -length), y: point.y)
        
        // Start point for vertical line (offset from corner)
        let verticalStart = CGPoint(x: point.x, y: point.y + offsetY)
        let verticalEnd = CGPoint(x: point.x, y: point.y + (isVertical ? length : -length))
        
        // Draw horizontal line
        path.move(to: horizontalStart)
        path.addLine(to: horizontalEnd)
        
        // Draw vertical line
        path.move(to: verticalStart)
        path.addLine(to: verticalEnd)
        
        // Draw the rounded corner connecting the two lines
        path.move(to: horizontalStart)
        
        // Create a small arc to connect the horizontal and vertical lines
        let centerX = point.x + (isHorizontal ? radius : -radius)
        let centerY = point.y + (isVertical ? radius : -radius)
        let center = CGPoint(x: centerX, y: centerY)
        
        let startAngle: CGFloat
        let endAngle: CGFloat
        
        if isHorizontal && isVertical {
            // Top-left corner
            startAngle = CGFloat.pi
            endAngle = 3 * CGFloat.pi / 2
        } else if !isHorizontal && isVertical {
            // Top-right corner
            startAngle = 3 * CGFloat.pi / 2
            endAngle = 0
        } else if isHorizontal && !isVertical {
            // Bottom-left corner
            startAngle = CGFloat.pi / 2
            endAngle = CGFloat.pi
        } else {
            // Bottom-right corner
            startAngle = 0
            endAngle = CGFloat.pi / 2
        }
        
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        corner.path = path.cgPath
        return corner
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard !hasScanned else { return }
        hasScanned = true
        
        captureSession?.stopRunning()
        animationTimer?.invalidate()
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              !stringValue.isEmpty else {
            // Invalid or empty QR code
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.completion?(.failure(.invalidQRCode))
            }
            return
        }
        
        // Validate QR code format (basic validation)
        if isValidQRCode(stringValue) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.completion?(.success(stringValue))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.completion?(.failure(.invalidQRCode))
            }
        }
    }
    
    private func isValidQRCode(_ qrCode: String) -> Bool {
        // Trim whitespace
        let trimmedCode = qrCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check basic length requirements
        guard !trimmedCode.isEmpty && trimmedCode.count >= 3 && trimmedCode.count <= 1000 else {
            return false
        }
        
        // Reject URLs immediately
        if trimmedCode.lowercased().hasPrefix("http://") || 
           trimmedCode.lowercased().hasPrefix("https://") ||
           trimmedCode.lowercased().hasPrefix("www.") ||
           trimmedCode.contains("://") {
            return false
        }
        
        // Check if it's a JSON format (expected format for cards)
        if trimmedCode.hasPrefix("{") && trimmedCode.hasSuffix("}") {
            // Try to parse as JSON to validate structure
            guard let data = trimmedCode.data(using: .utf8) else { return false }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check for required fields: uuid, athlete_id, user_id
                    let hasUuid = json["uuid"] is String && !(json["uuid"] as! String).isEmpty
                    let hasAthleteId = json["athlete_id"] != nil
                    let hasUserId = json["user_id"] != nil
                    
                    return hasUuid && hasAthleteId && hasUserId
                }
            } catch {
                return false
            }
        }
        
        // For non-JSON formats, check if it looks like a valid card ID
        // (alphanumeric, hyphens, underscores only)
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let characterSet = CharacterSet(charactersIn: trimmedCode)
        
        return allowedCharacters.isSuperset(of: characterSet) && trimmedCode.count >= 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
        
        // Update overlay when view is resized
        scannerOverlayView?.removeFromSuperview()
        animationTimer?.invalidate()
        
        setupOverlay()
    }
    
    deinit {
        animationTimer?.invalidate()
        captureSession?.stopRunning()
    }
}
