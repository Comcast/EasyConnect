
/**
 *  @file  Extension.swift
 *  @brief Adding more functionality to an existing Class using Extension
 */

import UIKit
import Foundation
import AMDots

/* Adding addtion functionality to UIViewController */
extension UIViewController {
    
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: Constants.ALERT_OK_BUTTON, style: .default) { action in
            print("You've pressed OK Button")
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

/* Adding addtion functionality to UIColor */
extension UIColor {
    
    convenience init(argb: UInt){
        self.init(
            red: CGFloat((argb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((argb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(argb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

/* Adding addtion functionality to UIView */
extension UIView {

    func setbackgroundImage() -> UIImageView
    {
           let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: Constants.EASYCONNECT_BACKGROUND_IMAGE)
           backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFill
           return backgroundImage
    }

}

/* Adding addtion functionality to Notification.Name */
extension Notification.Name {
    static let QRScanCode_Completion_Notification = Notification.Name(Constants.QRSCAN_COMPLETION_CODE_NOTIFICATION)
    static let ReloadUI_notification = Notification.Name(Constants.RELOADUI_NOTIFICATION)

}
