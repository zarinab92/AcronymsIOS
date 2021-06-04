//
//  Auth.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/8/21.
//

import UIKit

class Auth {
    
    static let shared = Auth()
    
    private init() {}
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        }
        set {
            if let newToken = newValue {
                UserDefaults.standard.setValue(newToken, forKey: "token")
            } else {
                UserDefaults.standard.removeObject(forKey: "token")
            }
            
        }
    }
    
    func login(token: String) {
        self.token = token
        
        DispatchQueue.main.async {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let acronymsNavigationController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            sceneDelegate?.window?.rootViewController = acronymsNavigationController
        }
    }
    
    func logOut() {
        self.token = nil
        
        DispatchQueue.main.async {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let loginNavigationController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(identifier: "LoginNavigation")
            sceneDelegate?.window?.rootViewController = loginNavigationController
        }
    }
}
