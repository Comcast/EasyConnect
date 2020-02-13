/**
*  @file  APIManager.swift
*  @brief The class file created for HTTPHeaders.
*/

import Foundation
import Alamofire
import SwiftKeychainWrapper

class APIManager {

    /**
    * @brief Httpheader creation with content type and AuthToken
    * @return HTTPHeaders.
    */
    
    class func tokenHeaders() -> HTTPHeaders {
        
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let authToken = KeychainWrapper.standard.string(forKey: Constants.TOKEN) {
            
            headers["X-Authorization-Token"] = authToken
        }
        return headers
    }
}
