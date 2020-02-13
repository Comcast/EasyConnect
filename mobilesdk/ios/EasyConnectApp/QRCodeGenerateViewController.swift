
/**
 *  @file  ServicesViewController.swift
 *  @brief The class file created for QRCodeGenerate.
 */

import UIKit

class QRCodeGenerateViewController: UIViewController {

    @IBOutlet var qrcodeImageView: UIImageView!
    
     let  obj = QRCodegenerator()
    
    override func viewDidLoad() {
        
        self.title = Constants.QRCODE_GENERATOR
    
      self.view.insertSubview(self.view.setbackgroundImage(), at: 0)
         
        /*Button customized with corner radius */
         qrcodeImageView.layer.cornerRadius = 15
         qrcodeImageView.layer.borderWidth = 1.5

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if GlobalData.sharedManager.dpp_uri.count == 0 {
            
            qrcodeImageView.backgroundColor = UIColor.white
            qrcodeImageView.image = UIImage(named: Constants.QRCODE_GENERATOR_DEFAULT_IMAGE)
            self.presentAlert(withTitle: Constants.ERROR_MESSAGE, message: Constants.UNABLE_TO_GET_DPP_URI)
            
         } else {
            
            qrcodeImageView.backgroundColor = UIColor.clear
            qrcodeImageView.image = obj.generateQRCodeImage(GlobalData.sharedManager.dpp_uri, avatarImage: nil)
        }
        
        super.viewDidAppear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
