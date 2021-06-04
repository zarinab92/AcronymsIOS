//
//  Router.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/23/21.
//

import Foundation


// https://acronyms-vapor.herokuapp.com/api/acronyms
enum Router {
    
    case getAllAcronyms
    case getAcronym(id: String)
    case createAcronym(acronym: Acronym)
    case updateAcronym(id: String, acronym: Acronym)
    case deleteAcronym(id: String)
    case searchFor(term: String)
    case signup(user: User)
    case login(username: String, password: String)
    case appleLogin(siwaToken: SigninWithAppleToken)
    case googleLogin
    case getUserInfo
    case uploadImage(image: ImageUploadData)
    case loadImage
    
    var scheme: String {
        switch self {
        case .getAllAcronyms, .createAcronym, .deleteAcronym, .getAcronym, .updateAcronym, .searchFor, .signup, .login, .appleLogin, .googleLogin, .getUserInfo, .uploadImage, .loadImage:
            return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getAllAcronyms, .createAcronym,.deleteAcronym, .getAcronym, .updateAcronym, .searchFor, .signup, .login, .appleLogin, .googleLogin, .getUserInfo, .uploadImage, .loadImage:
            return "acronyms-vapor.herokuapp.com"
        }
    }
    
    var port: Int? {
        switch self {
        case .getAllAcronyms, .createAcronym,.deleteAcronym, .getAcronym, .updateAcronym, .searchFor, .signup, .login, .appleLogin, .googleLogin, .getUserInfo, .uploadImage, .loadImage:
            return nil //8080
        }
    }
    
    var path: String {
        switch self {
        case .getAllAcronyms, .createAcronym:
            return "/api/acronyms"
        case .deleteAcronym(id: let id), .getAcronym(id: let id):
            return "/api/acronyms/\(id)"
        case .updateAcronym(id: let id, acronym: _):
            return "/api/acronyms/\(id)"
        case .searchFor:
            return "/api/acronyms/search"
        case .signup:
            return "/api/users"
        case .login:
            return "/api/users/login"
        case .appleLogin:
            return "/login-apple"
        case .googleLogin:
            return "/login-google"
        case .getUserInfo:
            return "/api/users/info"
        case .uploadImage:
            return "/api/users/profileImage"
        case .loadImage:
            return "/api/users/profileImage"
            
        }
    }
    
    var queryParameters: [URLQueryItem]? {
        switch self {
        case .getAllAcronyms, .createAcronym, .deleteAcronym, .getAcronym, .updateAcronym, .signup, .login, .appleLogin, .googleLogin, .getUserInfo, .uploadImage, .loadImage:
            return nil
        case .searchFor(term: let searchString):
            return [URLQueryItem(name: "term", value: searchString)]
        }

    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllAcronyms, .getAcronym, .searchFor, .getUserInfo, .loadImage:
            return .get
        case .createAcronym, .signup, .login, .appleLogin, .googleLogin, .uploadImage:
            return .post
        case .deleteAcronym:
            return .delete
        case .updateAcronym:
            return .put
        }
    }
    
    var header: [String:String] {
        var headers: [String:String] = ["Content-Type":"application/json"]
        let auth = Auth.shared
        
        switch self {
        case .createAcronym, .deleteAcronym, .updateAcronym, .getUserInfo, .uploadImage, .loadImage:
            headers ["Authorization"] = "Bearer \(auth.token ?? "")"
        case .getAllAcronyms, .getAcronym, .searchFor, .signup, .appleLogin, .googleLogin:
            return headers
        case .login(username: let username, password: let password):
            if let basicString = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() {
                headers ["Authorization"] = "Basic \(basicString)"
            }
        }
        
        return headers
    }
    
    var body: Data? {
        
        let encoder = JSONEncoder()
        
        switch self {
        case .getAllAcronyms, .getAcronym, .deleteAcronym, .searchFor, .login, .googleLogin, .getUserInfo, .loadImage:
            return nil
        case .createAcronym(acronym: let acronym), .updateAcronym(id: _, acronym: let acronym):
            return try? encoder.encode(acronym)
        case .signup(user: let user):
            return try? encoder.encode(user)
        case .appleLogin(siwaToken: let siwaToken):
            return try? encoder.encode(siwaToken)
        case .uploadImage(image: let uploadData):
            return try? encoder.encode(uploadData)
        }
    }
    
    var url: URL? {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryParameters
        
        return components.url
    }
}


// API REST_API Documentation

/*
 
 CRUD operations -> create (POST), read (GET), update (PUT), delete (DELETE)
 
 POST http://127.0.0.1:8080/api/acronyms -> create acronym (body -> JSON)
 Acronym -> JSON: {short: "LOL", long: "Laughing Out Loud"}
 
 GET http://127.0.0.1:8080/api/acronyms -> read all acronyms -> [Acronym]

 GET http://127.0.0.1:8080/api/acronyms/:id -> get acronym with id
 
 PUT http://127.0.0.1:8080/api/acronyms/:id -> update existing acronym
 Acronym -> JSON: {short: "LOL", long: "Laughing Out Loud"}
 
 DELETE http://127.0.0.1:8080/api/acronyms/:id -> delete existing acronym
 
 GET http://127.0.0.1:8080/api/acronyms/search?term=LOL -> searching for LOL acronym on server
 
 GET http://127.0.0.1:8080/api/acronyms/sorted -> get all acronyms sorted
 
 POST http://127.0.0.1:8080/api/users -> create user
 
 POST http://127.0.0.1:8080/api/users/login -> get token
 
 POST http://127.0.0.1:8080/api/users/:id/profileImage -> upload profile picture for user
 
 */
