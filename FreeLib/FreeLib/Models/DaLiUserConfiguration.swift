//
//  DaLiUserConfiguration.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/22/19.
//
import Foundation

class DaLiUserConfiguration {
    private var userKey = ""
    private var userToken = ""
    private var packageName = ""
    private var deviceID = ""
    private var domainList = [""]
    private var sdType = SDType.FULL
    private var header = ""
    
    init() {}
    
    init(userKey: String, userToken: String, packageName: String, deviceID: String,
         domainList: [String], sdType: SDType, header: String) {
        self.userKey = userKey
        self.userToken = userToken
        self.packageName = packageName
        self.deviceID = deviceID
        self.domainList = domainList
        self.sdType = sdType
        self.header = header
    }
    
    func setUserKey(userKey: String) { self.userKey = userKey }
    func getUserKey() -> String { return self.userKey }
    
    func setUserToken(userToken: String) { self.userToken = userToken }
    func getUserToken() -> String { return self.userToken }
    
    func setPackageName(packageName: String) { self.packageName = packageName }
    func getPackageName() -> String { return self.packageName }
    
    func setDeviceID(deviceID: String) { self.deviceID = deviceID }
    func getDeviceID() -> String { return self.deviceID }
    
    func setDomainList(domainList: [String]) { self.domainList = domainList }
    func getDomainList() -> [String] { return self.domainList }
    
    func setSdType(sdType: SDType) { self.sdType = sdType }
    func getSdType() -> SDType { return self.sdType }
    
    func setHeader(header: String) { self.header = header }
    func getHeader() -> String { return self.header }
    
}
