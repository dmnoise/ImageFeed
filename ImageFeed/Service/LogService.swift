//
//  LogService.swift
//  ImageFeed
//
//  Created by Dmitriy Noise on 15.04.2025.
//

import Foundation

final class LogService {
    
    static func error(function: String = #function, type: String? = nil, _ text: String) {
        
        print("❌ Error: \(function) - \(type ?? "") [\(text)]")
    }
}
