
/**
 *  @file  QRScanCode.swift
 *  @brief Implementation of all utility functions in QRScanCode APIs
 */

import UIKit
import AVFoundation

public class QRScanCode: NSObject {
    
    /* Create the capture session */
    var captureSession = AVCaptureSession()
    
    /* Create the preview layer */
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    /* Get tha QRCode Frame View */
    var qrCodeFrameView: UIView?
    
    /* Corner line width */
    var lineWidth: CGFloat
    
    /* Corner stroke color */
    var strokeColor: UIColor
    
    /* completion hanlder call back  */
    var completedCallBack: ((_ stringValue: String) -> ())?
    
    /* Scan rect, default is the bounds of the scan view, can modify it if need */
    open var scanFrameView: UIView = UIView(frame: CGRect.zero)
    
    /*Values identifying the suported type of metadata objects.*/
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    /**
     * @brief QRScanCode class init
     */
    
    public override init() {
        self.lineWidth = 4
        self.strokeColor = UIColor.green
        super.init()
    }
    
    /**
     * @brief Scan prepare scan QRCode and get Uri
     * @param view the scan view, the preview layer and the drawing layer will be insert into this view.
     * @param Completion handler call back string will retrun QRCode scan uri.
     */
    
   public func scanQRCodeToGetUri(_ view: UIView, completion:@escaping (_ stringValue: String)->()) {
        
        completedCallBack = completion
        
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            
            print("camera permission already authorized")
            scanFrameView = view
            getInputScanFrame()
            
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.scanFrameView = view
                        self.getInputScanFrame()
                    }
                    print("camera permission granted")
                } else {
                    self.completedCallBack!(Constants.CAMERA_ACCESS_DENIED)
                    return
                }
            })
        }
    }
    
    /**
     * @brief Scan area design frame
     * @param view Inputview for scan frame.
     */
    
    //Opening Brace Spacing Violation: Opening braces should be preceded by a single space
    //and on the same line as the declaration. (opening_brace)
    private func getInputScanFrame() {
        // Observer for screen orientation changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(screen_Rotated),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print(Constants.CAMERA_ERROR_MESSAGE)
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            
            // If the input can be added, add it to the session.
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            //// Configuration failed. Handle error.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = scanFrameView.layer.bounds
        scanFrameView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor =  self.strokeColor.cgColor
            qrCodeFrameView.layer.borderWidth = self.lineWidth
            scanFrameView.addSubview(qrCodeFrameView)
            scanFrameView.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    /// stop scan
   public func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    /// start scan
   public func startRunning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    /**
     * @brief Handle screen roation events and update the frames.
     */
    
    @objc func screen_Rotated() {
        
        if let connection =  self.videoPreviewLayer?.connection {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection: AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }
    
    /**
     * @brief Scan QRCode and get Uri
     * @param layer Inputview for scan frame.
     * @param orientation To get the screen orientation.
     */
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = scanFrameView.bounds
    }
    
    /* Perform Deinitialization Process */
    deinit {
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        //Remover observer notification
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

/*!
 @protocol AVCaptureMetadataOutputObjectsDelegate
 @abstract
 Defines an interface for delegates of AVCaptureMetadataOutput to receive emitted objects.
 */
extension QRScanCode: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            completedCallBack!(Constants.QR_CODE_ERROR_MESSAGE)
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the
            //QR code metadata (or barcode) then update the statuslabel's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                completedCallBack!(metadataObj.stringValue!)
            }
        }
    }
    
}
