import SwiftUI
import AVFoundation

struct QRScannerView: UIViewRepresentable {
    typealias UIViewType = ScannerUIView
    var completion: (String) -> Void
    
    func makeUIView(context: Context) -> ScannerUIView {
        let view = ScannerUIView()
        view.completion = completion
        return view
    }
    
    func updateUIView(_ uiView: ScannerUIView, context: Context) {
        // No update needed
    }
}

class ScannerUIView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var completion: ((String) -> Void)?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var scannerOverlayView: UIView?
    private var animationTimer: Timer?
    private var isAnimatingUp = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }
    
    func setupSession() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            self.layer.addSublayer(previewLayer)
        }
        
        setupOverlay()
        captureSession.startRunning()
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
        
        let path = UIBezierPath()
        path.move(to: point)
        
        let horizontalPoint = CGPoint(x: point.x + (isHorizontal ? length : -length), y: point.y)
        let verticalPoint = CGPoint(x: point.x, y: point.y + (isVertical ? length : -length))
        
        path.addLine(to: horizontalPoint)
        path.move(to: point)
        path.addLine(to: verticalPoint)
        
        corner.path = path.cgPath
        return corner
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        animationTimer?.invalidate()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Delay the completion by a moment to show the successful scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.completion?(stringValue)
            }
        }
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
    }
}
