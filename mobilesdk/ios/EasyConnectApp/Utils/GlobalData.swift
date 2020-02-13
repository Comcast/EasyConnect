
/**
 *  @file  GlobalData.swift
 *  @brief It is a globally accessable parameter that is specific to the class.
 */
import UIKit
 
class GlobalData {
    
    /* These are the properties you can store in your singleton */
    
    /* To store iPaddress value in global instance */
    var ipAddress: String = ""
    
    /* To store scan_coduri value in global instance */
    var scanCodUri: String = ""
    
     /* To store portNumber value in global instance */
    var portNumber: String = ""
    
    /* To store URL for text log file */
    var archiveUrl: URL?
    
    /* To store DPP URI for global instance */
    var dpp_uri: String = ""
    
    /* To store HTTP URL for global instance */
    var http_url: String = ""
    
    /* To store HTTP URL for global instance */
    var manual_MDN_Selection: Bool = false

     /* Singleton class init */
    class var sharedManager: GlobalData {
        struct Static {
            
            static let instance = GlobalData()
        }
        return Static.instance
    }
}
