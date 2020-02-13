/**
 *  @file  NetworkConnections.swift
 *  @brief Implementation of Network related functions(CURL Operations).
 */

import UIKit
import Alamofire
import SwiftKeychainWrapper
//protocol class to value paass
protocol serviceResultDelegate {
    
    func serviceResponse(message: String, whichCase: String)
    func showErrorMessage(title: String, subTitle: String )
}

class NetworkDataParser: NSObject {
    
    var AFManager = SessionManager()
    
    var textLog = TextLog()
    
    var serviceResponseDelegate: serviceResultDelegate?
    
    /**
    * @brief Network calls for HTTP GET and POST methods and condition checked with status codes
    * @Param choose the HTTP method type.
    * @Param inputParam for post methods.
    * @Param network service call.
    * @Param add headers for authorization and token.
    */
    func network_service(methodType: String, inputParam: [String: Any]?,
                         weburl: String, headers: HTTPHeaders? ) {
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            switch methodType {
            case Constants.METHOD_GET :
                
                AFManager.request(weburl, method: .get, encoding: JSONEncoding.default, headers: nil)
                    .validate(statusCode: 200..<501)
                    .responseJSON { response in
                        let statusCode =  response.response?.statusCode
                        
                        switch response.result {
                            
                        case .success(let json):
                            
                            if statusCode == Constants.ERROR_CODE_200 {
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let dppUri = itemJson[Constants.DPP_URI] as? String {
                                        GlobalData.sharedManager.dpp_uri = dppUri
                                    }
                                    self.textLog.write("Received access point DPP URI successfully \n")
                                    
                                    self.serviceResponseDelegate?.showErrorMessage(title: Constants.SUCCESS_MESSAGE,
                                                                                   subTitle: "Received access point DPP URI successfully")
                                    print(json)
                                }
                            } else  if statusCode ==  Constants.ERROR_CODE_307 {
                                self.textLog.write("Received error 'Temporary redirect' from configurator with Status code 307 \n")
                                
                                self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE,
                                                                               subTitle: "Temporary Redirect. DPP URI of AP not received")
                            } else  if statusCode ==  Constants.ERROR_CODE_400 {
                                
                                self.textLog.write("Received error 'Bad Request or Invalid parameters' from configurator with Status code 400 \n")
                                NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                                self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE,
                                                                               subTitle: "Bad Request or Invalid parameters.DPP URI of AP not received")
                            } else  if statusCode ==  Constants.ERROR_CODE_401 {
                                self.textLog.write("WiFi passphrase requested\n")
                                NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    self.serviceResponseDelegate?.serviceResponse(message: itemJson[Constants.MESSAGE] as! String, whichCase: "useCase2")
                                }
                            } else  if statusCode ==  Constants.ERROR_CODE_404 {
                                
                                self.textLog.write("Received error 'Not Found' from configurator with Status code 404 \n")
                                self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: "Not Found.DPP URI of AP not received")
                            } else  if statusCode ==  Constants.ERROR_CODE_500 {
                                
                                self.textLog.write("Received error 'Internal Server Error' from configurator with Status code 500 \n")
                                
                                self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: "Internal Server Error.DPP URI of AP not received")
                            }
                            
                            NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                            
                        case .failure(let error):
                            
                            if error._code == NSURLErrorTimedOut {
                                
                                print("Request timeout!")
                                self.textLog.write("Request timeout \n")
                            }
                            NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                            
                        }
                }
                
            case Constants.METHOD_POST :
                
                var finalHeader: HTTPHeaders = HTTPHeaders()
                finalHeader = headers ?? HTTPHeaders()
                
                AFManager.request(weburl, method: .post, parameters: inputParam!, encoding: JSONEncoding.default, headers: finalHeader)
                    .validate(statusCode: 200..<501)
                    .responseJSON { response in
                        let statusCode =  response.response?.statusCode
                       
                        switch response.result {
                            
                        case .success(let json):
                            
                            DispatchQueue.main.async {
                                print("success",json)
                            }
                            if statusCode == Constants.ERROR_CODE_200 {
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let token = itemJson[Constants.TOKEN] as? String {
                                        
                                        KeychainWrapper.standard.set(token, forKey: Constants.TOKEN)
                                    }
                                    self.serviceResponseDelegate?.showErrorMessage(title: Constants.SUCCESS_MESSAGE,
                                                                                   subTitle: Constants.DPP_CONNECTION_SUCCESS_MESSAGE)
                                }
                                
                                self.textLog.write("Received message Success from configurator with Status code 200\n")
                            } else if statusCode ==  Constants.ERROR_CODE_307 {
                                
                                self.textLog.write("Received error 'Temporary redirect' from configurator with Status code 307\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            } else if statusCode == Constants.ERROR_CODE_400 {
                                self.textLog.write("Received error 'Bad Request or Invalid parameters' from configurator with Status code 400\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            } else if statusCode == Constants.ERROR_CODE_401 {
                                
                                self.textLog.write("WiFi passphrase requested\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    KeychainWrapper.standard.removeObject(forKey: Constants.TOKEN)
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.serviceResponse(message: detailMessage, whichCase: "useCase1")
                                        
                                    }
                                }
                            } else if statusCode == Constants.ERROR_CODE_404 {
                                
                                self.textLog.write("Received error 'Not Found' from configurator with Status code 404\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            } else if statusCode == Constants.ERROR_CODE_500 {
                                
                                self.textLog.write("Received error 'Internal Server Error' from configurator with Status code 500\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            }
                            NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                            
                        case .failure(let error):
                            
                            DispatchQueue.main.async {
                                print("failure",error)
                            }
                            if statusCode ==  Constants.ERROR_CODE_307 {
                                
                                self.textLog.write("Received error 'Temporary redirect' from configurator with Status code 307\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            }  else if statusCode == Constants.ERROR_CODE_400 {
                                self.textLog.write("Received error 'Bad Request or Invalid parameters' from configurator with Status code 400\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }
                                }
                            }
                            else if statusCode == Constants.ERROR_CODE_401 {
                                
                                self.textLog.write("WiFi passphrase requested \n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    
                                    KeychainWrapper.standard.removeObject(forKey: Constants.TOKEN)
                                    self.serviceResponseDelegate?.serviceResponse(message: itemJson[Constants.MESSAGE] as! String, whichCase: "useCase1")
                                }
                            } else if statusCode == Constants.ERROR_CODE_500 {
                                
                                self.textLog.write("Received error 'Internal Server Error' from configurator with Status code 500\n")
                                
                                if let  itemJson = response.result.value as? [String: Any] {
                                    if let detailMessage = itemJson[Constants.MESSAGE] as? String
                                    {
                                        self.serviceResponseDelegate?.showErrorMessage(title: Constants.ERROR_MESSAGE, subTitle: detailMessage)
                                    }                                }
                            }
                            else if error._code == NSURLErrorTimedOut {
                                print("Request timeout!")
                                self.textLog.write("Request timeout \n")
                            }
                            NotificationCenter.default.post(name: .ReloadUI_notification, object: nil)
                            
                        }
                }
                
            default:
                print("Invalid choice")
            }
            // do some tasks..
        } else {
            print("No! internet is not available.")
        }
    }
    
    /**
    * @brief Functionality for GET method webservice call.
    * @Param Webservice url.
    */
    func getQRCodeURI( weburl: String) {
        self.network_service(methodType: Constants.METHOD_GET, inputParam: nil, weburl: weburl, headers: nil)
    }
    
    override init() {
        
        super.init()
        
        timeoutConfigure()
    }
    
    /**
    * @brief Time interval sets 120 seconds.
    */

    func timeoutConfigure() {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest  = 60 // seconds
        configuration.timeoutIntervalForResource = 60 //seconds
        AFManager = Alamofire.SessionManager(configuration: configuration)
    }
}
