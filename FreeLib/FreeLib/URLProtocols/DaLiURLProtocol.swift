//
//  DaLiURLProtocol.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/17/19.
//
import Foundation

class DaLiURLProtocol: URLProtocol {
    
    struct Constants {
        static let RequestHandledKey = "URLProtocolRequestHandled"
        static let INSIDE = "inside"
    }
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    var httpAdditionalHeaders: [AnyHashable: Any]?
    
    var sdKey = ""
    var proxyIP = ""
    var proxyPort = 0
    var header = ""
    static var domainList = [""]
    static var sdType: SDType?
    
    // Sends user to DaLi Proxy
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        print("Request ✅: URL = \(String(describing: request.url?.absoluteString))")
        if session == nil {
            
            // Getting Device ID and eliminating "-" character
            let deviceID = UIDevice.current.identifierForVendor!.uuidString.replacingOccurrences(of: "-", with: "",
                                                                                                 options: NSString.CompareOptions.literal,
                                                                                                 range:nil)
            
            // Sends an Advice notification to CRM
            sdKey = Utils.DALI_USER_CONFIG.getUserKey()
            header = Utils.DALI_USER_CONFIG.getHeader()
            Utils.advice(destinyUrl: request.url!.absoluteString, sdKey: sdKey, deviceID: deviceID)
            
            // Getting Proxy IP, Port
            proxyIP = Utils.ACTIVATE_OBJECT.getProxyIP()
            proxyPort = Utils.ACTIVATE_OBJECT.getProxyPort()
            
            // Configuring proxy into session
            let configuration = URLSessionConfiguration.default
            print("DaLiURLProtocol Header:", header)
            httpAdditionalHeaders = [Utils.USER_AGENT: header+"Dali; key_campaign-\(sdKey); deviceId-\(deviceID); FinDali"]
            configuration.httpAdditionalHeaders = httpAdditionalHeaders
            configuration.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            configuration.connectionProxyDictionary = [AnyHashable: Any]()
            configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable as String] = 1
            configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPProxy as String] = proxyIP
            configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPPort as String] = proxyPort
            configuration.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyHost as String] = proxyIP
            configuration.connectionProxyDictionary?[kCFStreamPropertyHTTPSProxyPort as String] = proxyPort
            
            // Defining session
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
    }
    
    // Handle of requests
    override class func canInit(with request: URLRequest) -> Bool {
        if DaLiURLProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
            return false
        }
        
        if Utils.IS_WIFI_ACTIVE {
            print("DaLiURLProtocol WiFi Active return false:")
            return false
        }
        
        // Checking if DaLi was turned on/off by developer
        if !Utils.getDaLiState() {
            print("DaLiURLProtocol DaLi State:", Utils.getDaLiState())
            return false
        }
        
        // Checking if request is from DaLi and sending to CRM directly
        if (request.url?.absoluteString.contains("crm.datoslibres.mx"))! {
            return false
        }
        
        // If user is off specific zone, don't send request through DaLi Proxy
        let insidePolygon = Utils.GEOMETRIES_OBJECT.getGeometries()[Constants.INSIDE] as! Bool
        if Utils.ACTIVATE_OBJECT.getGeometries() && !insidePolygon {
            DispatchQueue.main.async {
                Utils.toastMessage("GPS: Fuera del Polygono permitido", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
                print("DaLiURLProtocol Geometries status", false)
            }
            return false
        }
        
        // Getting black/white list
        DaLiURLProtocol.domainList = Utils.DALI_USER_CONFIG.getDomainList()
        
        // Getting SD Mode Type
        DaLiURLProtocol.sdType = Utils.DALI_USER_CONFIG.getSdType()
        
        // Checking if SD Type is FULL and has no blacklist
        if DaLiURLProtocol.sdType == SDType.FULL
            && DaLiURLProtocol.domainList.count == 1
            && DaLiURLProtocol.domainList[0] == "" {
            print("DaLiURLProtocol Inside FULL True", DaLiURLProtocol.domainList.count)
            return true
        }
        
        // Checking if SD Type is Full and excluding blacklist URL's
        if DaLiURLProtocol.sdType == SDType.FULL
            && !DaLiURLProtocol.domainList.contains((request.url!.absoluteString)) {
            print("DaLiURLProtocol Inside FULL wit blacklist: True")
            return true
        }
        
        // Checking if SD Type is SINGLE and accessing only whitelist URL's
        if DaLiURLProtocol.sdType == SDType.SINGLE
            && DaLiURLProtocol.domainList.contains((request.url!.absoluteString)) {
            print("DaLiURLProtocol Inside SINGLE True")
            return true
        }
        
        // If no rule matched, access url directly
        print("DaLiURLProtocol no rule matched return: false")
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        DaLiURLProtocol.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
    }
}

extension DaLiURLProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else { return }
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        let sender = challenge.sender
        
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                sender?.use(credential, for: challenge)
                completionHandler(.useCredential, credential)
                return
            }
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
}


