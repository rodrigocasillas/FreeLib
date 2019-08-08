//
//  ActivateJSON.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/17/19.
//
import Foundation
import UIKit

class ActivateJSON: Decodable {
    private var success = false
    private var hint = ""
    private var geometries = false
    private var time_interval: Int?
    private var proxy_ip = ""
    private var proxy_port = 0
    
    init() {}
    
    init(proxy_ip: String, hint: String, time_interval: Int, success: Bool, geometries: Bool, proxy_port: Int) {
        self.proxy_ip = proxy_ip
        self.hint = hint
        self.time_interval = time_interval
        self.success = success
        self.geometries = geometries
        self.proxy_port = proxy_port
    }
    
    func setSuccess(success: Bool) { self.success = success }
    func getSuccess() -> Bool { return self.success }
    
    func setHint(hint: String) { self.hint = hint }
    func getHint() -> String { return self.hint }
    
    func setGeometries(geometries: Bool) { self.geometries = geometries }
    func getGeometries() -> Bool { return self.geometries }
    
    func setTimeInterval(time_interval: Int) { self.time_interval = time_interval }
    func getTimeInterval() -> Int { return self.time_interval ?? 0 }
    
    func setProxyIP(proxy_ip: String) { self.proxy_ip = proxy_ip }
    func getProxyIP() -> String { return self.proxy_ip }
    
    func setProxyPort(proxy_port: Int) { self.proxy_port = proxy_port }
    func getProxyPort() -> Int { return self.proxy_port }
    
    func showValues() {
        print("Activate success:", self.success)
        print("Activate hint:", self.hint)
        print("Activate geometries:", self.geometries)
        print("Activate time_interval:", self.time_interval ?? 0)
        print("Activate proxy_ip:", self.proxy_ip)
        print("Activate proxy_port:", self.proxy_port)
        print("-------------------------", "--------------------------")
    }
}
