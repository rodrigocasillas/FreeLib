//
//  DaLiConfiguration.swift
//  CocoaLib
//
//  Created by Rodrigo Casillas on 7/17/19.
//
import Foundation

class DaLiConfiguration {
    
    init(config: URLSessionConfiguration) {
        
    }
    
    public static func config() {
        URLProtocol.registerClass(DaLiURLProtocol.self)
    }
}
