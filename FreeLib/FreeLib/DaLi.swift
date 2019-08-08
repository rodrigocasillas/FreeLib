//
//  DaLi.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/12/19.
//

import Foundation
import UIKit
import CoreLocation

public enum SDType {
    case FULL
    case SINGLE
}

public class DaLi {
    
    // Class Constants
    private static let DEVICE_ID = "device_id";
    private static let KEY = "daLiKey";
    private static let DALI_SDK_TOKEN = "daLiSDKToken";
    private static let TOKEN_TYPE = "tokenType";
    private static let RANDOM_KEY = "randomKey";
    private static let GPS_INTERVALS = "gps intervals";
    private static let KB_CONSUMED = "kb_consumed";
    private static let GEOMETRIES = "geometries";
    private static let FIRST_TIME = "firstTime";
    private static let CARRIER_NAME = "carrierName";
    private static let INTERVALS = "intervals";
    
    // Class Variables
    private static var daliKey = "none"
    private static var daliSDKToken = "none"
    private static var domainList = [String]()
    private static var sdType = SDType.SINGLE
    private static var packageName = "none"
    private static var systemVersion = "none"
    private static var carrierName = "none"
    private static var deviceName = "none"
    private static var deviceInfo = "none"
    private static var deviceID = "none"
    private static var systemOS = "iOS"
    private static var header = ""
    
    // Location variables
    let locationManager = CLLocationManager()
    
    // Avoid instantiantion of class
    private init(){}
    
    // DaLi Activation Methods
    public static func activate(daliKey: String, daliSDKToken: String, domainList: [String], sdType: SDType) {
        
        // Getting iPhone, system info and user credentials.
        self.daliKey = daliKey
        self.daliSDKToken = daliSDKToken
        self.domainList = domainList
        self.sdType = sdType
        self.packageName = Bundle.main.bundleIdentifier!
        self.systemVersion = UIDevice.current.systemVersion
        self.carrierName = Utils.getCarrier()
        self.deviceName = UIDevice.current.name
        self.deviceInfo = UIDevice.current.modelName
        
        // Cleaning device ID
        self.deviceID = cleanDeviceID(rawDeviceID: UIDevice.current.identifierForVendor!.uuidString)
        
        // Setting user configuration
        userConfig(daliKey: self.daliKey, daliSDKToken: self.daliSDKToken,
                   packageName: self.packageName, deviceID: self.deviceID,
                   domainList: self.domainList, sdType: self.sdType, header: self.header)
        
        // Making request to Activate SDK
        Utils.activate(sdKey: self.daliKey,sdToken: self.daliSDKToken,
                       deviceID: self.deviceID, deviceInfo: self.deviceInfo,
                       system: self.systemOS, systemVersion: self.systemVersion,
                       carrierName: self.carrierName, packageName: self.packageName)
        
        // Showing parameter settings in console
        showParameters()
    }
    
    public static func activate(daliKey: String, daliSDKToken: String, domainList: [String], sdType: SDType, header: String) {
        
        // Getting iPhone, system info and user credentials.
        self.daliKey = daliKey
        self.daliSDKToken = daliSDKToken
        self.domainList = domainList
        self.sdType = sdType
        self.header = header
        self.packageName = Bundle.main.bundleIdentifier!
        self.systemVersion = UIDevice.current.systemVersion
        self.carrierName = Utils.getCarrier()
        self.deviceName = UIDevice.current.name
        self.deviceInfo = UIDevice.current.modelName
        
        // Cleaning device ID
        self.deviceID = cleanDeviceID(rawDeviceID: UIDevice.current.identifierForVendor!.uuidString)
        
        // Setting user configuration
        userConfig(daliKey: self.daliKey, daliSDKToken: self.daliSDKToken,
                   packageName: self.packageName, deviceID: self.deviceID,
                   domainList: self.domainList, sdType: self.sdType, header: self.header)
        
        // Making request to Activate SDK
        Utils.activate(sdKey: self.daliKey,sdToken: self.daliSDKToken,
                       deviceID: self.deviceID, deviceInfo: self.deviceInfo,
                       system: self.systemOS, systemVersion: self.systemVersion,
                       carrierName: self.carrierName, packageName: self.packageName)
        
        // Showing parameter settings in console
        showParameters()
    }
    
    public static func activate(daliKey: String, daliSDKToken: String, sdType: SDType) {
        
        // Getting iPhone, system info and user credentials.
        self.daliKey = daliKey
        self.daliSDKToken = daliSDKToken
        self.domainList = [""]
        self.sdType = sdType
        self.packageName = Bundle.main.bundleIdentifier!
        self.systemVersion = UIDevice.current.systemVersion
        self.carrierName = Utils.getCarrier()
        self.deviceName = UIDevice.current.name
        self.deviceInfo = UIDevice.current.modelName
        // Cleaning device ID
        self.deviceID = cleanDeviceID(rawDeviceID: UIDevice.current.identifierForVendor!.uuidString)
        
        // Setting user configuration
        userConfig(daliKey: self.daliKey, daliSDKToken: self.daliSDKToken,
                   packageName: self.packageName, deviceID: self.deviceID,
                   domainList: self.domainList, sdType: self.sdType, header: self.header)
        
        // Making request to Activate SDK
        Utils.activate(sdKey: self.daliKey,sdToken: self.daliSDKToken,
                       deviceID: self.deviceID, deviceInfo: self.deviceInfo,
                       system: self.systemOS, systemVersion: self.systemVersion,
                       carrierName: self.carrierName, packageName: self.packageName)
        
        // Showing parameter settings in console
        showParameters()
    }
    
    // Removes "-" character from deviceID
    public static func cleanDeviceID(rawDeviceID: String) -> String {
        return rawDeviceID.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil)
    }
    
    public static func userConfig(daliKey: String, daliSDKToken: String,
                                  packageName: String, deviceID: String,
                                  domainList: [String], sdType: SDType, header: String) {
        Utils.DALI_USER_CONFIG.setUserKey(userKey: daliKey)
        Utils.DALI_USER_CONFIG.setUserToken(userToken: daliSDKToken)
        Utils.DALI_USER_CONFIG.setPackageName(packageName: packageName)
        Utils.DALI_USER_CONFIG.setDeviceID(deviceID: deviceID)
        Utils.DALI_USER_CONFIG.setDomainList(domainList: domainList)
        Utils.DALI_USER_CONFIG.setSdType(sdType: sdType)
        Utils.DALI_USER_CONFIG.setHeader(header: header)
    }
    
    public static func register(session: URLSessionConfiguration) -> URLSessionConfiguration {
        session.protocolClasses?.insert(DaLiURLProtocol.self, at: 0)
        return session
        
    }
    
    public static func getAnalytics() -> Double {
        return Utils.ANALYTICS_OBJECT.getKBConsumed()
    }
    
    public static func startDaLi() {
        Utils.setDaLiState(isDaliActive: true)
    }
    
    public static func stopDaLi() {
        Utils.setDaLiState(isDaliActive: false)
    }
    
    public static func showParameters() {
        print("DaliKey:", self.daliKey)
        print("DaliSDKToken:", self.daliSDKToken)
        print("DomainList:", self.domainList)
        print("SDType:", self.sdType)
        print("PackageName:", self.packageName)
        print("SystemVersion:", self.systemVersion)
        print("CarrierName:", self.carrierName)
        print("DeviceName:", self.deviceName)
        print("DeviceInfo:", self.deviceInfo)
        print("DeviceID:", self.deviceID)
        print("-------------------------", "--------------------------")
    }
    
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "i386", "x86_64":                          return "Simulator"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        default:                                        return identifier
        }
    }
    
}

