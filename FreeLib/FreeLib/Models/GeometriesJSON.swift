//
//  CoordinatesJSON.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/24/19.
//
import Foundation

class GeometriesJSON {
    
    // This does not extend decodable because
    // it has a more complex JSON Structure to parse.
    private var status = false
    private var campaignStatus = ""
    private var analytics = ["": ""] as [String : Any]
    private var hint = ""
    private var geometries = ["time_interval": 0, "specific_zone": false, "inside": false] as [String : Any]
    private var expiredData = false
    
    init() {}
    init(json: [String: Any]) {
        self.status = json["status"] as! Bool
        self.campaignStatus = json["campaign_status"] as! String
        self.analytics = json["analytics"] as! [String: Any]
        self.hint = json["hint"] as! String
        self.geometries = json["geometries"] as! [String: Any]
        if self.status { self.expiredData = json["expired_data"] as! Bool }
        else {self.expiredData = false}
    }
    
    func setStatus(status: Bool) { self.status = status }
    func getStatus() -> Bool { return self.status }
    
    func setCampaignStatus(campaignStatus: String) { self.campaignStatus = campaignStatus }
    func getCampaignStatus() -> String { return self.campaignStatus }
    
    func setAnalytics(analytics: [String: Any] ) { self.analytics = analytics }
    func getAnalytics() -> [String: Any] { return self.analytics }
    
    func setHint(hint: String ) { self.hint = hint }
    func getHint() -> String { return self.hint }
    
    func setGeometries(geometries: [String: Any] ) { self.geometries = geometries }
    func getGeometries() -> [String: Any] { return self.geometries }
    
    func setExpiredData(expiredData: Bool) { self.expiredData = expiredData }
    func getExpiredData() -> Bool { return self.expiredData }
    
    func showValues() {
        print("Geometries status:", self.status)
        print("Geometries campaign status:", self.campaignStatus)
        print("Geometries analytics:", self.analytics)
        print("Geometries hint:", self.hint)
        print("Geometries geometries:", self.geometries)
        print("Geometries expired_data:", self.expiredData)
        print("-------------------------", "--------------------------")
    }
}
