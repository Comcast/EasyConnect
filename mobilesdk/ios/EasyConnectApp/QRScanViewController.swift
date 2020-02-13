/**
*  @file  QRScanViewController.swift
*  @brief Implementation of all utility functions in QRScanCode APIs
*/

import UIKit
import AVFoundation

class QRScanViewController: UIViewController {

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    let scanner = QRScanCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "QRCode Scanner"
        
        scanner.scanQRCodeToGetUri(view) { (stringValue) -> () in
            print(stringValue)
        
            if (stringValue == Constants.QR_CODE_ERROR_MESSAGE) {
                self.presentAlert(withTitle: "Error", message: "Please scan again")
                self.scanner.startRunning()
            
            } else {
                GlobalData.sharedManager.scanCodUri = stringValue
                self.launchApp(decodedURL: stringValue)
            }
        }
    }

  // MARK: - Helper methods

  func launchApp(decodedURL: String) {

    scanner.stopRunning()
    
      if presentedViewController != nil {
          return
      }

      let alertPrompt = UIAlertController(title: "Scan Result", message: "Your decode url is \(decodedURL)", preferredStyle: .actionSheet)
      let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in

      self.navigationController?.popViewController(animated: true)
      NotificationCenter.default.post(name: .QRScanCode_Completion_Notification, object: nil)

      })

    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
        
        self.scanner.startRunning()
    })
      alertPrompt.addAction(confirmAction)
      alertPrompt.addAction(cancelAction)
      present(alertPrompt, animated: true, completion: nil)
  }

    @IBAction func homeScreen_back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }

}
