
/**
 *  @file  Constants.swift
 *  @brief Declaration of constant strings
 */

import Foundation

public struct Constants {

    /************ SERVER URL ************/
    
    public static let CONFIGURE_URL: String = "/api/v1/configurator-initiate-dpp"
    
    public static let CONFIGURE_URL_USE_CASE2: String = "/api/v1/configurator-dpp-uri"
    
    public static let MANUAL_CONFIGURE_URL: String =  "10.0.0.1:80"
    
    /************ SERVER HTTP METHODS ************/
    public static let METHOD_GET: String = "GET"
    public static let METHOD_POST: String = "POST"
    
    public static let MESSAGE: String = "message"
    public static let STATUS: String  = "status"
    public static let TOKEN: String   = "token"
    public static let DPP_URI: String = "dpp_uri"

    /************ SERVER ERROR CODES & ERROR MESSAGES ************/
    public static let ERROR_CODE_200        : Int          = 200
    public static let ERROR_MESSAGE_200     : String       = "Success"
    
    public static let ERROR_CODE_307        : Int = 307
    public static let ERROR_MESSAGE_307     : String = "Temporary Redirect"
    
    public static let ERROR_CODE_400        : Int = 400
    public static let ERROR_MESSAGE_400     : String = "Bad Request or Invalid parameters"
    
    public static let ERROR_CODE_401        : Int = 401
    public static let ERROR_MESSAGE_401     : String = "Unauthorized"

    public static let ERROR_CODE_404        : Int = 404
    public static let ERROR_MESSAGE_404     : String = "Not Found"
    
    public static let ERROR_CODE_500        : Int = 500
    public static let ERROR_MESSAGE_500     : String = "Internal Server Error"
    
    public static let DPP_CONNECTION_SUCCESS_MESSAGE : String  = "Dpp Connection initiated"
    public static let WiFi_PASSPHRASE : String  = "Enter WiFi passphrase?"
    public static let ANSWER_YOUR_QUESTION : String  = "Answer your question"
    
    public static let SUCCESS_MESSAGE       : String  = "Success"
    public static let ERROR_MESSAGE         : String  = "Error"
    public static let INFO_MESSAGE          : String  = "Info"
    public static let TIMEOUT_ERROR_MESSAGE : String  = "Request timeout!"

    /********    No Internet Connection     **********/
    public static let NO_INTERNET_CONNECTION_MESSAGE : String = "Please check your internet connection"
    
    /********    Scan QR Code     **********/
    public static let  QR_CODE_ERROR_MESSAGE : String = "No valid configurator detected,Try again"
    public static let  CAMERA_ERROR_MESSAGE : String = "Failed to get the camera device"
    public static let  CAMERA_ACCESS_DENIED : String = "Camera Access denied"
    public static let SCAN_QRCODE_GET_URI : String  = "Please scan the QRcode and get the URI"
    public static let SELECT_MDNS_GET_IPADDRESS : String  = "First select your MDNS Discovery name to get an IP Address"
    
    /********    QRCode Generator     **********/

    public static let QRCODE_GENERATOR : String  = "QRCode Generator"
    public static let QRCODE_GENERATOR_DEFAULT_IMAGE : String = "lauchIm"

    /********    NET SERVICE DISCOVERY     **********/
    
    public static let DOMAIN_NAME : String = "local"
    public static let  SERVICE_TYPE: String = "_dpp._tcp"

    public static let NO_MDNS_CONFIGURATORS_DETECTED : String  = "No configurators detected. Please ensure configurator is on and click 'Scan for Configurator' from the settings menu"
   public static let MANUAL_CONFIGURATOR : String = "No configurators detected. If you wish to enter the configurator IP and port manually, please enter the value"
    
    public static let SET_MANUAL_CONFIGURATOR : String = "Enter the configurator IP and port manually!"

    /********    ALERT BUTTON ACTION NAMES     **********/
    public static let ALERT_OK_BUTTON: String = "OK"
    
     /********    SEGUE IDENTIFIERS     **********/
    public static let MDNS_DISCOVERY_POPUP: String = "popupView"
    public static let QRCODE_GEN_VIEW_CONTROLLER_ID: String = "QRcodeGeneratorView"

    
     /********    DPP URI     **********/
    public static let UNABLE_TO_GET_DPP_URI: String = "Unable to get QRCode from DPP URI"
    
    /********    NOTIFICATION NAMES    **********/
    public static let QRSCAN_COMPLETION_CODE_NOTIFICATION: String = "QRScanCode_Completion_Notification"
    public static let RELOADUI_NOTIFICATION: String = "ReloadUI_notification"
    
    /********    IMAGE NAMES    **********/
   
    public static let EASYCONNECT_BACKGROUND_IMAGE: String = "easyconnect_vertical"
    
    /********    IDENTIFIERS    **********/

    public static let CUSTOM_CELL_IDENTIFIER: String = "customCell"

}
