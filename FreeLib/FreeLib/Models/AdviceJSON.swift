//
//  AdviceJSON.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/18/19.
//

import Foundation
import UIKit

class AdviceJSON: Decodable {
    private var success = false
    
    init() {}
    init(success: Bool) {
        self.success = success
    }
    
    func setSuccess(success: Bool){self.success = success}
    func getSuccess() -> Bool { return self.success }
    
    func showValues() {
        print("Advice success:", self.success)
    }
}
