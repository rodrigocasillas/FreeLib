//
//  AnalyticsJSON.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/23/19.
//
import Foundation

class AnalyticsJSON: Decodable {
    private var status = false
    private var hint = ""
    private var kb_consumed = 0.0
    
    init() {}
    
    init(status: Bool, hint: String, kb_consumed: Double) {
        self.status = status
        self.hint = hint
        self.kb_consumed = kb_consumed
    }
    
    func setStatus(status: Bool) { self.status = status }
    func getStatus() -> Bool { return self.status }
    
    func setHint(hint: String) { self.hint = hint }
    func getHint() -> String { return self.hint }
    
    func setKBConsumed(kb_consumed: Double) { self.kb_consumed = kb_consumed }
    func getKBConsumed() -> Double { return self.kb_consumed }
    
    func showValues() {
        print("Utils Analytics status:", self.status)
        print("Utils Analytics hint:", self.hint)
        print("Utils Analytics kb consumed:", self.kb_consumed)
        print("-------------------------", "--------------------------")
    }
}
