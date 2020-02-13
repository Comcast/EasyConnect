/**
 *  @file  MDNSDiscoveryController.swift
 *  @brief Predefined class based on single view application - Implemention file.
 */

import UIKit

class MDNSDiscoveryController: UIViewController, serviceResultDelegate {
    
    func serviceResponse(message: String, whichCase: String) {
        
    }
    
    func showErrorMessage(title: String, subTitle: String) {
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
             let okAction = UIAlertAction(title: Constants.ALERT_OK_BUTTON, style: .default) { action in
                 print("You've pressed OK Button")
             }
        alertController.addAction(okAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    let networkObject = NetworkDataParser()

    @IBOutlet var popupView: UIView!
    // Instance of the service that we're looking for
    var serviceOne: NetService?
    
    var textLog = TextLog()
    
    @IBAction func dismissPopover(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var discoveryTable: UITableView!
    
    // Instance of the service that we're looking for
      var services = [NetService]()

    override func viewDidLoad() {
        
        popupView.layer.cornerRadius = 15
        popupView.layer.borderWidth = 1.5
        popupView.layer.borderColor = UIColor.gray.cgColor
        
       // discoveryTable.layer.borderColor = UIColor.red.cgColor
       // logTableView.layer.borderWidth = 1
        //discoveryTable.layer.cornerRadius = 10
        
        serviceOne = nil
        self.title = "MDNS Discovery"
        discoveryTable.tableFooterView  = UIView(frame: .zero)
        
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
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

extension MDNSDiscoveryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        cell.nameLabel.text = services[indexPath.row].name
        return cell
    }
}

extension MDNSDiscoveryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        textLog.write( "\(services[indexPath.row].name) configurator selected \n")
        
        self.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.removeObserver(self, name: .ReloadUI_notification, object: nil)

       // Resolve the service in 5 seconds
       serviceOne = services[indexPath.row]
       serviceOne?.delegate = self
       serviceOne?.resolve(withTimeout: 5)
       tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return "MDNS Discovery List"
    }
}

extension MDNSDiscoveryController: NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        debugPrint(errorDict)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else { return }
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                // handle error
                return
            }
            let sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        let ipAddress = String(cString: hostname)
        
        print("ipAddress", ipAddress)
        print("port", sender.port)
        
        GlobalData.sharedManager.ipAddress = ipAddress
        GlobalData.sharedManager.portNumber = String(sender.port)
        
        GlobalData.sharedManager.http_url = "http://\(GlobalData.sharedManager.ipAddress):\(GlobalData.sharedManager.portNumber)"
        
        if (GlobalData.sharedManager.manual_MDN_Selection == false) {
        
        let usecase2url = "\(GlobalData.sharedManager.http_url)\(Constants.CONFIGURE_URL_USE_CASE2)"
        //\(Constants.CONFIGURE_URL_USE_CASE2
        networkObject.serviceResponseDelegate = self
        networkObject.getQRCodeURI(weburl: usecase2url)
        }
    }
}
