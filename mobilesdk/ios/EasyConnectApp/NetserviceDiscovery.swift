
/**
 *  @file  NetserviceDiscovery.swift
 *  @brief Implementation of NetService Discovery Settings.
 */

import UIKit

//protocol class declaration
protocol discoveryDelegate {
    //Discovery services callback method.
    func finishDiscovery(serviceDiscovery: [NetService])
}

class NetserviceDiscovery: NSObject {
    
    var textLog = TextLog()
    
    // Deleagate object
    var discoveryDelegate: discoveryDelegate?
    
    // Instance of the service that we're looking for
    var netservice: NetService?

    // Local service browser
    var browser: NetServiceBrowser!
    
    // Instance of the service that we're looking for
    var services = [NetService]()
    
    // Search for services
    func startSearch() {
        
        self.services.removeAll()
  
        // Setup the browser
        self.browser = NetServiceBrowser()
        self.browser.delegate = self
        self.browser.searchForServices(ofType: Constants.SERVICE_TYPE, inDomain: Constants.DOMAIN_NAME)
    }
    // Stop the serach
    func stopsearch() {
          self.browser.stop()
    }
    
    deinit {
        discoveryDelegate = nil
    }
}
/* The interface a net service browser uses to inform a delegate about the state of service discovery.*/
extension NetserviceDiscovery: NetServiceBrowserDelegate {
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
       
        print("Search about to begin..")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Search stopped")
        discoveryDelegate?.finishDiscovery(serviceDiscovery: services)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        print("error in search")
        debugPrint(errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
        print("Discovered the service")
        print("- name:", service.name)
        print("- port:", service.port)
        print("- type", service.type)
        print("- domain:", service.domain)

        services.append(service)
       
        if (!moreComing) {
            
            if services.count == 1 {
                // Resolve the service in 5 seconds
                netservice = services[0]
                netservice?.delegate = self
                netservice?.resolve(withTimeout: 5)
                textLog.write("Selected \(netservice!.name) as Configurator \n")
                 NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)

            } else {
                print("more than oneeeeee founddddd")
                self.browser.stop()
            }
          service.stopMonitoring()
        }
    }
    
   func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
       if let index = self.services.firstIndex(of: service) {
           self.services.remove(at: index)
           print("removing a service")
       }
   }
}
/* The interface a net service uses to inform its delegate about the state of the service it offers.*/
extension NetserviceDiscovery: NetServiceDelegate {
    
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

    }
}
