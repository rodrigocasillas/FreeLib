//
//  Utils.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/17/19.
//
import Foundation
import UIKit
import CoreTelephony
import CoreLocation

class Utils: UIViewController {
    
    // DaLi URL Constants
    public static let ACTIVATE_BASE_URL = "https://crm.datoslibres.mx/api/sdk/activate"
    public static let ADVICE_BASE_URL = "https://crm.datoslibres.mx/api/sdk/advice"
    public static let ANALYTICS_BASE_URL = "https://crm.datoslibres.mx/api/sdk/analytics"
    public static let GEOMETRIES_BASE_URL = "https://crm.datoslibres.mx/api/sdk/extended/"
    
    // DaLi Network JSON constants
    public static let POST = "POST"
    public static let GET = "GET"
    public static let KEY = "key"
    public static let ACCEPT = "Accept"
    public static let DEVICE_ID = "device_id"
    public static let AUTHORIZATION = "Authorization"
    public static let ACCESS = "Accept"
    public static let APPLICATION_JSON = "application/json"
    public static let SPACE = " "
    public static let TOKEN_TYPE = "token_type"
    public static let EXPIRES_IN = "expires_in"
    public static let ACCESS_TOKEN = "access_token"
    public static let STATUS = "status"
    public static let KB_CONSUMED = "kb_consumed"
    public static let MESSAGE = "message"
    public static let GEOMETRIES = "geometries"
    public static let SEQUENCE = "sequence"
    public static let SEQUENCE_STATUS_OK = "sequence_status_ok"
    public static let TIME_INTERVAL = "time_interval"
    public static let BUNDLE_ID = "package-name"
    public static let CARRIER = "carrier"
    public static let PROXY_IP = "proxy_ip"
    public static let PROXY_PORT = "proxy_port"
    public static let BEARER = "Bearer "
    public static let DEVICE_INFO = "device_info"
    public static let SYSTEM_OS = "system"
    public static let SYSTEM_VERSION = "system_version"
    public static let CARRIER_NAME = "carrier_name"
    public static let SUCCESS = "success"
    public static let SYSTEM = "system"
    public static let PACKAGE_NAME = "package-name"
    public static let URL_ = "url"
    public static let AND = "&"
    
    // DaLi Protocol Constants
    public static let USER_AGENT = "User-Agent"
    public static let DEVICE_ID_HEADER = "device-id"
    
    // DaLi class variables
    public static var ACTIVATE_OBJECT = ActivateJSON()
    public static var DALI_USER_CONFIG = DaLiUserConfiguration()
    public static var ANALYTICS_OBJECT = AnalyticsJSON()
    public static var GEOMETRIES_OBJECT = GeometriesJSON()
    public static var ADVICE_OBJECT = AdviceJSON()
    public static var ANALYTICS_TIMER = Timer()
    public static var GPS_TIMER = Timer()
    public static var WIFI_CHECK_TIMER = Timer()
    public static let LOCATION_MANAGER = CLLocationManager()
    
    // DaLi Constants
    public static let DALI_READY = """
                  Esta APP no consume tus datos
                  celulares, navega libremente.
                  """
    public static let DALI_FAILURE = """
                  No se han podido habilitar
                  tus datos libres.
                  """
    public static let DISABLE_WIFI = """
                  Desctiva tu conexion WiFi,
                  para usar el servicio.
                  """
    public static let SD_ENABLED = """
                  WiFi desactivado,
                  datos libres activados.
                  """
    public static let DALI_ACTIVE = "Datos libres activados"
    public static let DALI_DISABLED = "Datos libres deshabilitados"
    public static var DALI_SERVICE_STATE = false
    public static let COULD_NOT_ACTIVATE = "No se pudo activar datos libres\n"
    public static let VERIFY_INFO = "Verifica los datos introducidos"
    public static var IS_WIFI_ACTIVE = false
    
    
    // Makes an Activation request to DaLi API
    public static func activate(sdKey: String, sdToken: String,
                                deviceID: String, deviceInfo: String,
                                system: String, systemVersion: String,
                                carrierName: String, packageName: String) {
        
        // Making Session configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [Utils.ACCEPT:Utils.APPLICATION_JSON, Utils.AUTHORIZATION: Utils.BEARER + sdToken]
        let session = URLSession(configuration: configuration)
        
        let urlString = Utils.ACTIVATE_BASE_URL
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 5
        urlRequest.httpMethod = POST
        let postString = "\(Utils.KEY)=\(sdKey)&\(Utils.DEVICE_ID)=\(deviceID)&\(Utils.DEVICE_INFO)=\(deviceInfo)&\(Utils.SYSTEM)=\(system)&\(Utils.SYSTEM_VERSION)=\(systemVersion)&\(Utils.CARRIER_NAME)=\(carrierName)&\(Utils.PACKAGE_NAME)=\(packageName)"
        urlRequest.httpBody = postString.data(using: .utf8)
        
        // Starting Request
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            print("Utils Activation:", String(data: data!, encoding: .utf8)!)
            
            // Assigning JSON parameters to model
            do {
                // Checking if response/success was true
                checkSuccess(data: data!)
                
                ACTIVATE_OBJECT = try JSONDecoder().decode(ActivateJSON.self, from: data!)
                ACTIVATE_OBJECT.showValues()
                
                // Activates SDK Locally
                DispatchQueue.main.async {
                    if ACTIVATE_OBJECT.getSuccess() {
                        DaLiConfiguration.config()
                        Utils.periodicalAnalytic()
                        Utils.getAnalytics()
                        self.toastMessage(DALI_READY, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
                        Utils.wifiCheckTimer(3)
                    } else { self.toastMessage(DALI_FAILURE, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)) }
                    
                    // If campaign is of GPS, start getting coordinates
                    if ACTIVATE_OBJECT.getGeometries() {
                        Utils.getGPSLocation()
                        Utils.startGPSTimer(Double(ACTIVATE_OBJECT.getTimeInterval()))
                    }
                    
                }
            } catch let jsonErr {
                print("Utils Activate error:", jsonErr.localizedDescription)
            }
            
        }
        
        // Execute HTTP request
        task.resume()
    }
    
    
    // Request API for analytics
    public static func getAnalytics() {
        // Making Session configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [Utils.ACCEPT: Utils.APPLICATION_JSON,
                                               Utils.AUTHORIZATION: Utils.BEARER + DALI_USER_CONFIG.getUserToken(),
                                               KEY: DALI_USER_CONFIG.getUserKey(),
                                               DEVICE_ID_HEADER: DALI_USER_CONFIG.getDeviceID()]
        
        let urlString = Utils.ANALYTICS_BASE_URL
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = GET
        
        let session = URLSession(configuration: configuration)
        
        // Starting request
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // Ensure there is no error for this HTTP response
            guard error == nil else {
                print ("Utils error: \(error!)")
                return
            }
            
            print("Utils Analytics:", String(data: data!, encoding: .utf8)!)
            do {
                // Defining Analytics object for internal use
                ANALYTICS_OBJECT = try JSONDecoder().decode(AnalyticsJSON.self, from: data!)
                ANALYTICS_OBJECT.showValues()
                
            } catch let jsonErr {
                print("Utils Analytics error:",jsonErr.localizedDescription)
            }
        }
        
        // Execute HTTP request
        task.resume()
    }
    
    // // Starts timer to get user analytics every certain time
    public static func periodicalAnalytic() {
        ANALYTICS_TIMER = Timer.scheduledTimer(timeInterval: 15,
                                               target: self,
                                               selector: #selector(periodicalAnalytics),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    // Gets client analytics from API
    @objc static func periodicalAnalytics() {
        print("Analytics")
        // DaLi is Activated start
        // getting analytics
        if DALI_SERVICE_STATE {
            Utils.getAnalytics()
        }
    }
    
    // Getting phone carrier name
    public static func getCarrier() -> String {
        var carrier = ""
        #if targetEnvironment(simulator)
        carrier = "simulator"
        #else
        if  CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName != nil {
            let networkInfo = CTTelephonyNetworkInfo()
            carrier = (networkInfo.subscriberCellularProvider?.carrierName)!
            let allowedSet =  NSCharacterSet(charactersIn:"&").inverted
            let scapedCarrierName = carrier.addingPercentEncoding(withAllowedCharacters: allowedSet)
            carrier = scapedCarrierName!
        } else {
            carrier = "nocarrier"
        }
        #endif
        return carrier
    }
    
    // Notifies API which URL's this client is requesting
    public static func advice(destinyUrl: String, sdKey: String, deviceID: String) {
        // Making Session configuration
        let configuration = URLSessionConfiguration.default
        
        configuration.httpAdditionalHeaders = [Utils.ACCEPT: Utils.APPLICATION_JSON,
                                               Utils.AUTHORIZATION: Utils.BEARER + DALI_USER_CONFIG.getUserToken()]
        let session = URLSession(configuration: configuration)
        
        let urlString = Utils.ADVICE_BASE_URL
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = POST
        let postString = "\(Utils.KEY)=\(sdKey)&\(Utils.DEVICE_ID)=\(deviceID)&\(Utils.URL_)=\(destinyUrl)&\(Utils.PACKAGE_NAME)=\(DALI_USER_CONFIG.getPackageName())"
        
        urlRequest.httpBody = postString.data(using: .utf8)
        
        // Starting request
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // Ensure there is no error for this HTTP response
            guard error == nil else {
                print ("Utils error: \(error!)")
                return
            }
            
            do {
                // Defining Advice response object for internal use
                ADVICE_OBJECT = try JSONDecoder().decode(AdviceJSON.self, from: data!)
                ADVICE_OBJECT.showValues()
            } catch let jsonErr {
                print(jsonErr.localizedDescription)
            }
        }
        
        // Execute HTTP request
        task.resume()
    }
    
    // Starts timer to get user coordinates every certain time
    public static func startGPSTimer(_ timeInterval: Double) {
        GPS_TIMER = Timer.scheduledTimer(timeInterval: timeInterval/1000,
                                         target: self,
                                         selector: #selector(getGPSLocation),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    // Gets user coordinantes from GPS Service
    @objc public static func getGPSLocation() {
        LOCATION_MANAGER.desiredAccuracy = kCLLocationAccuracyHundredMeters
        LOCATION_MANAGER.requestWhenInUseAuthorization()
        LOCATION_MANAGER.desiredAccuracy = kCLLocationAccuracyBest
        LOCATION_MANAGER.startUpdatingLocation()
        var currentLocation: CLLocation!
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
            || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            currentLocation = LOCATION_MANAGER.location
            
            // If there is no location then return
            if currentLocation == nil {return}
            let latitude = String(format: "%.7f", currentLocation.coordinate.latitude)
            let longitude = String(format: "%.7f", currentLocation.coordinate.longitude)
            
            print("Utils Coordinates Latitude:", latitude)
            print("Utils Coordinates Longitude:", longitude)
            // If DaLi is Active then start requesting user GPS
            // validation.
            print("Geometries")
            geometriesValidation(lat: latitude, lng: longitude)
            
            
        } else {
            print("DaLi: ", "No se han otorgado permisos para usar el GPS")
        }
        
    }
    
    // Request an API validation at given user coordinates
    public static func geometriesValidation(lat: String, lng: String) {
        // If DaLi is Active then request for
        // GPS Validations.
        // Making Session configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [Utils.ACCEPT: Utils.APPLICATION_JSON,
                                               Utils.AUTHORIZATION: Utils.BEARER + DALI_USER_CONFIG.getUserToken(),
                                               KEY: DALI_USER_CONFIG.getUserKey(),
                                               DEVICE_ID_HEADER: DALI_USER_CONFIG.getDeviceID(),
                                               PACKAGE_NAME: Bundle.main.bundleIdentifier!]
        let session = URLSession(configuration: configuration)
        let urlString = Utils.GEOMETRIES_BASE_URL + lat + AND + lng
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = GET
        
        // Starting request
        let task = session.dataTask(with: urlRequest) { data, response, error in
            
            // Ensure there is no error for this HTTP response
            guard error == nil else {
                print ("Utils Geometries Response Error: \(error!)")
                return
            }
            
            print("Utils Geometries:", String(data: data!, encoding: .utf8)!)
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    GEOMETRIES_OBJECT = GeometriesJSON(json: json)
                    GEOMETRIES_OBJECT.showValues()
                }
                
            } catch let jsonErr {
                print("Error serializing GeometriesJSON", jsonErr.localizedDescription)
            }
        }
        
        // Execute HTTP request
        task.resume()
    }
    
    // Changes DaLi on/off variables state
    public static func setDaLiState(isDaliActive: Bool) {
        DALI_SERVICE_STATE = isDaliActive
        if DALI_SERVICE_STATE { toastMessage(DALI_ACTIVE, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)) }
        if !DALI_SERVICE_STATE { toastMessage(DALI_DISABLED, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))}
    }
    
    public static func getDaLiState() -> Bool{
        return DALI_SERVICE_STATE
    }
    
    // When JSON response from Activate method returns false
    // decodable from ActivateJSON class for some reason can't parse it,
    // which is why this method was made to read a false responde
    static func checkSuccess(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // If Activate method parameters are wrong
                // API returns only a message parameter: value
                // the basic structure is not respected
                let message = json["message"] as? String
                if message != nil {
                    DispatchQueue.main.async {
                        showToast(text: message!)
                    }
                    return
                }
                let success = json["success"] as? Bool
                let hint = json["hint"] as! String
                if !success! {
                    DispatchQueue.main.async {
                        showToast(text: COULD_NOT_ACTIVATE + hint)
                        return
                    }
                }
                
                
            }
        } catch let jsonErr {
            print("Utils Activate error:", jsonErr.localizedDescription)
        }
    }
    
    static func showToast(text: String) {
        DispatchQueue.main.async {
            self.toastMessage(text, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
            
        }
    }
    
    // Starts timer to get user coordinates every certain time
    public static func wifiCheckTimer(_ timeInterval: Double) {
        WIFI_CHECK_TIMER = Timer.scheduledTimer(timeInterval: timeInterval,
                                                target: self,
                                                selector: #selector(isWiFiActive),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    // Gets Wifi active state
    private static var SHOW_TOAST_STATE = true
    @objc static func isWiFiActive() -> Bool {
        let reachability = Reachability()!
        switch reachability.connection {
        case .wifi:
            IS_WIFI_ACTIVE = true
            print("Utils Internet connection:", "wifi")
            if SHOW_TOAST_STATE { self.toastMessage(DISABLE_WIFI, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1));SHOW_TOAST_STATE = false }
            return true
        case .cellular:
            IS_WIFI_ACTIVE = false
            if !SHOW_TOAST_STATE {self.toastMessage(SD_ENABLED, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)); SHOW_TOAST_STATE = true}
            print("Utils Internet connection:", "cellular")
            return false
        case .none:
            IS_WIFI_ACTIVE = false
            if !SHOW_TOAST_STATE {self.toastMessage(SD_ENABLED, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)); SHOW_TOAST_STATE = true}
            print("Utils Internet connection:", "none")
            return false
        case .vpn:
            IS_WIFI_ACTIVE = true
            if SHOW_TOAST_STATE {self.toastMessage(DISABLE_WIFI, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)); SHOW_TOAST_STATE = false}
            print("Utils Internet connection:", "vpn")
            return false
        }
    }
    
}



extension UIViewController {
    public static func toastMessage(_ message: String, color: UIColor) {
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.numberOfLines = 5
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 15)
        messageLbl.textColor = .black
        //messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)
        messageLbl.backgroundColor = color//UIColor(white: 0, alpha: 0.5)
        
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        
        messageLbl.frame = CGRect(x: 20, y: window.frame.height - 90, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 10, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }
}



