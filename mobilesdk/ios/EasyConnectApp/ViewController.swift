/**
 *  @file  AppDelegate.swift
 *  @brief Predefined class based on single view application selection - Implemention file.
 */

import UIKit
import Alamofire
import AMDots
import SwiftKeychainWrapper

class ViewController: UIViewController,serviceResultDelegate,discoveryDelegate {
    
    var manual_MDN_Selection: Bool?
    
    /* To display the logs in tableview */
    @IBOutlet var logTableView: UITableView!
    
    let commonObj  =  CommonMethods()
    
    /* MDNS Discovery button to navigate discovery viewcontroller */
    @IBOutlet var SettingsButton: UIButton!
    
    /* ScanQRCodeButton button to navigate SCANQR Code viewcontroller */
    @IBOutlet var scanQRCodeButton: UIButton!
    
    /* QRCodeGenerator button to navigate QRCodeGenerator viewcontroller */
    @IBOutlet var QRcodegeneratorButton: UIButton!
    
    /* NetworkConnections object for all CURL operations  */
    let networkObject = NetworkDataParser()
    
    let serviceDiscovery = NetserviceDiscovery()
    
    // Instance of the service that we're looking for
    var service = [NetService]()
    
    /* Object creation for TextLogs */
    var textLog = TextLog()
    
    /* Get the logs from TextLog class */
    var logsPool: [String] = [String]()
    
    /* Object for custom loader */
    var loaderObj = Loader()
    
    /*Gear button action */
    @IBAction func showSettingsAction(_ sender: Any) {
        showActionsheet()
    }
    override func viewDidLoad() {
        
        GlobalData.sharedManager.manual_MDN_Selection = false
        self.view.insertSubview(self.view.setbackgroundImage(), at: 0)
        
        /*Button customized with corner radius */
        scanQRCodeButton.backgroundColor = .white
        scanQRCodeButton.layer.cornerRadius = 10
        scanQRCodeButton.layer.borderWidth = 1.5
        scanQRCodeButton.layer.borderColor = UIColor.black.cgColor
        
        /*Button customized with corner radius */
        QRcodegeneratorButton.backgroundColor = .white
        QRcodegeneratorButton.layer.cornerRadius = 10
        QRcodegeneratorButton.layer.borderWidth = 1.5
        QRcodegeneratorButton.layer.borderColor = UIColor.black.cgColor
        
        /*Button customized with corner radius */
        logTableView.layer.cornerRadius = 15
        logTableView.layer.borderWidth = 1.5
        logTableView.tableFooterView  = UIView(frame: .zero)
        
        textLog.write("Scanning for Configurators \n")
        
        /* Netservice discovery object creation .*/
        serviceDiscovery.discoveryDelegate = self
        serviceDiscovery.startSearch()
        
        /* Register for QRcode completion handler notification . */
        NotificationCenter.default.addObserver(self,
                                    selector: #selector(delegateCallback(notification:)),
                                    name: .QRScanCode_Completion_Notification, object: nil)
        
        /* Register for Reload UI notification for log status updates. */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(readlogandUpdateUI),
                                               name: .ReloadUI_notification, object: nil)
        
        /* Timer added for stop discovery method. */
        _ = Timer.scheduledTimer(timeInterval: 10,
                                 target: self,
                                 selector: #selector(timerCallback),
                                 userInfo: nil,
                                 repeats: false)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /**
     * @brief Reload the UI with Logs update and hide/show the loader
     */
    @objc func readlogandUpdateUI() {
        loaderObj.hideLoader()
        logsPool = textLog.readTextLog()
        logTableView.reloadData()
    }
    
    /**
     * @brief MDNS discovery for stop search after 10 mins search
     */
    @objc func timerCallback() {
        serviceDiscovery.stopsearch()
        textLog.write("Scanning stopped \n")
    }
    
    /* Handler callback from QRScancodeViewController. */
    @objc func delegateCallback(notification: NSNotification) {
        networkObject.serviceResponseDelegate = self
        
        if GlobalData.sharedManager.scanCodUri.count == 0 {
            
            self.presentAlert(withTitle: Constants.ERROR_MESSAGE, message: Constants.SCAN_QRCODE_GET_URI)
            
        } else if GlobalData.sharedManager.http_url.count == 0 {
            
            self.presentAlert(withTitle: Constants.ERROR_MESSAGE, message: Constants.SELECT_MDNS_GET_IPADDRESS)
            
        } else {

           let parameters = ["dpp_uri": GlobalData.sharedManager.scanCodUri]

            let usecase1url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL)"
            
            if let token = KeychainWrapper.standard.string(forKey: Constants.TOKEN) {
                
            print("token", token)
                
            sendUriToServer(inputParam: parameters, weburl: usecase1url, header: APIManager.tokenHeaders())
            } else {
                
                sendUriToServer(inputParam: parameters, weburl: usecase1url, header: nil)
            }
            
            textLog.write("Sending URI to configurator \n")
        }
        readlogandUpdateUI()
    }
    /**
     * @brief sendUriToServer
     * @param inputParam dpp_uri as a dictionary.
     * @param weburl  configure web url.
     */
    func sendUriToServer(inputParam: [String: String], weburl: String, header: HTTPHeaders? ) {
        
        networkObject.network_service(methodType: Constants.METHOD_POST,
                                      inputParam: inputParam,
                                      weburl: weburl, headers: header)
        loaderObj.showLoader(view: self.view)
    }
    
    /**
     * @brief showErrorMessage
     * @param title title for alert.
     * @param subTitle subTitle for alert.
     */
    func showErrorMessage(title: String, subTitle: String ) {
        readlogandUpdateUI()
        loaderObj.hideLoader()
        self.presentAlert(withTitle: title, message: subTitle)
    }
    
    func serviceResponse(message: String, whichCase: String) {
        
        readlogandUpdateUI()
        loaderObj.hideLoader()
        self.presentAlertWithInputBox(withTitle: Constants.INFO_MESSAGE, message: message, whichCase: whichCase )
    }
    
    func presentAlertWithInputBox(withTitle title: String, message: String, whichCase: String) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: Constants.ALERT_OK_BUTTON, style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            
            let headers = ["Content-Type": "application/json",
                           "X-Challenge-Response": textField!.text as Any] as [String: Any]
            self.textLog.write("WiFi passphrase sent\n")
            let parameters = ["dpp_uri": GlobalData.sharedManager.scanCodUri ]
            
            var usecase1url = ""
            if (whichCase == "useCase1") {
                
                usecase1url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL)"
            } else {
                
                usecase1url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL_USE_CASE2)"
            }
            self.networkObject.network_service(methodType: Constants.METHOD_POST,
                inputParam: parameters,
                weburl: usecase1url, headers: (headers as! HTTPHeaders))
            self.loaderObj.showLoader(view: self.view)
        })
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = Constants.ANSWER_YOUR_QUESTION
            textField.isSecureTextEntry = true
            self.textLog.write("Enter WiFi passphrase\n")
            saveAction.isEnabled = false
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = textField.text!.count > 0
            }
        }
        alert.addAction(saveAction)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        
        GlobalData.sharedManager.manual_MDN_Selection = false
        readlogandUpdateUI()
        super.viewDidAppear(animated)
    }
    
    func finishDiscovery(serviceDiscovery: [NetService]) {
        /* NetworkConnections object for all CURL operations  */
        
        if(serviceDiscovery.count == 0)
        {
            textLog.write("No configurators detected. Please ensure configurator is on and click 'Scan for Configurator' from the settings menu \n")
            
            commonObj.presentAlertWithInputBox(withTitle:  Constants.ERROR_MESSAGE, message: Constants.MANUAL_CONFIGURATOR, presentedOnViewController:self )
        }
        else if(serviceDiscovery.count == 1)
        {
            let usecase2url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL_USE_CASE2)"
            
            if (GlobalData.sharedManager.manual_MDN_Selection == false)
            {
                let networkObject = NetworkDataParser()
                networkObject.serviceResponseDelegate = self
                networkObject.getQRCodeURI(weburl: usecase2url)
            }
        }
        else
        {
            textLog.write("\(serviceDiscovery.count) configurators list found \n")
            service = serviceDiscovery
            self.performSegue(withIdentifier: Constants.MDNS_DISCOVERY_POPUP, sender: self)
        }
        
        readlogandUpdateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.MDNS_DISCOVERY_POPUP {
            if let obj = segue.destination as? MDNSDiscoveryController {
                obj.services = service
            }
        }

        //QRcodeGeneratorView
    }
    
    func showActionsheet() {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Settings Option", preferredStyle: .actionSheet)
        // 2
        let mdnsActionButton = UIAlertAction(title: "Scan Configurators", style: .default) { _ in
            
            _ = Timer.scheduledTimer(timeInterval: 10,
                                     target: self,
                                     selector: #selector(self.timerCallback),
                                     userInfo: nil, repeats: false)
            
            GlobalData.sharedManager.manual_MDN_Selection = true
            self.serviceDiscovery.startSearch()
        }
        // 3
        let getDPPURIAction = UIAlertAction(title: "Get AP DPP URI", style: .default) { _ in
            
            let usecase2url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL_USE_CASE2)"
            
            self.networkObject.serviceResponseDelegate = self
            self.networkObject.getQRCodeURI(weburl: usecase2url)
        }
        let manuallyConfig = UIAlertAction(title: "Add configurator manually", style: .default) { _ in
              
            self.commonObj.presentAlertWithInputBox(withTitle:  Constants.INFO_MESSAGE, message: Constants.SET_MANUAL_CONFIGURATOR, presentedOnViewController:self )
          }

        // 4
        optionMenu.addAction(manuallyConfig)
        optionMenu.addAction(mdnsActionButton)
        optionMenu.addAction(getDPPURIAction)
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        //        if let dotsV = dotsView
        //        {
        //             dotsV.stop()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //Navigate to QRCode generator view controller
    @IBAction func showActionQRCode(_ sender: Any) {
        
        if GlobalData.sharedManager.dpp_uri.count == 0 {
           
            self.presentAlert(withTitle: Constants.ERROR_MESSAGE, message: Constants.UNABLE_TO_GET_DPP_URI)

        } else {
            
            self.performSegue(withIdentifier: Constants.QRCODE_GEN_VIEW_CONTROLLER_ID, sender: self)
        }
        
    }
    
    /*The observer to remove in deinit method*/
    deinit {
        NotificationCenter.default.removeObserver(self, name: .QRScanCode_Completion_Notification, object: nil)
        //        NotificationCenter.default.removeObserver(self, name: .ReloadUI_notification, object: nil)
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsPool.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CUSTOM_CELL_IDENTIFIER,
            for: indexPath) as! CustomTableViewCell
        
        cell.logsLabel.text = logsPool[indexPath.row]
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


