
/**
 *  @file  CommonMethods.swift
 *  @brief Implementation class and instance method for global use.
 */

import UIKit

class CommonMethods: NSObject, serviceResultDelegate {
    
    func serviceResponse(message: String, whichCase: String) {
        print("message", message)
    }
    
    func showErrorMessage(title: String, subTitle: String) {
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
             let OKAction = UIAlertAction(title: Constants.ALERT_OK_BUTTON, style: .default) { action in
                 print("You've pressed OK Button")
             }
        alertController.addAction(OKAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
     
     var textLog = TextLog()
    
    /* NetworkConnections object for all CURL operations  */
    let networkObject = NetworkDataParser()

    func presentAlertWithInputBox(withTitle title: String,
                                  message: String,
                                  presentedOnViewController: UIViewController) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: Constants.ALERT_OK_BUTTON, style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
              
            if let inputtext = textField!.text {
                GlobalData.sharedManager.http_url = "http://\(inputtext)"
            }

            let usecase2url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL_USE_CASE2)"
            print("inputtext", usecase2url)
            
            self.textLog.write("Successfully set configurator as \( GlobalData.sharedManager.http_url) \n")
            //Successfully set configurator as (IP and port )
            NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)

            if GlobalData.sharedManager.manual_MDN_Selection == false {
            self.networkObject.serviceResponseDelegate = self
            self.networkObject.getQRCodeURI(weburl: usecase2url)
            }

        })
        
        //2. Add the text field. You can configure it however you need.
         alert.addTextField { (textField) in
            textField.text = Constants.MANUAL_CONFIGURE_URL
          NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
            saveAction.isEnabled = textField.text!.count > 0
            }
         }
        alert.addAction(saveAction)
        // 4. Present the alert.
         presentedOnViewController.present(alert, animated: true, completion: nil)
    }
}
