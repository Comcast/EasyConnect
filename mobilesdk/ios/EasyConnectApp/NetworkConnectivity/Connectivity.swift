/**
 *  @file  Connectivity.swift
 *  @brief Implementation of internet connectivity and connectivity listener functions.
 */


import UIKit
import Foundation
import Alamofire

class Connectivity {
    
    /* NetworkReachabilityManager will return internet reachable status*/
    static  let shared = NetworkReachabilityManager()
    
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    /**
     * @brief Starts monitoring the network availability status
     */
     class  func startMonitoring() {
        
        Connectivity.shared?.listener = { status in
            if  Connectivity.shared?.isReachable ?? false {
                
                switch status {

                case .reachable(.ethernetOrWiFi):
                    print("The network is reachable over the WiFi connection")
                    
                case .reachable(.wwan):
                    print("The network is reachable over the WWAN connection")
                    
                case .notReachable:
                    print("The network is not reachable")
                    
                case .unknown :
                    print("It is unknown whether the network is reachable")
                    
                }
            }
             Connectivity.shared?.startListening()
    }
}
}
