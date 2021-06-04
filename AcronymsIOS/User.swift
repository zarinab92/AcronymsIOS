//
//  User.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/7/21.
//

import Foundation

class User: Codable {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

struct PublicUser: Codable {
    let id: String
    let username: String
    let profileImage: String?
}
