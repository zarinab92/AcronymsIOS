//
//  Acronym.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/23/21.
//

import Foundation

struct Acronym: Codable {
    var id: String?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
    
}


