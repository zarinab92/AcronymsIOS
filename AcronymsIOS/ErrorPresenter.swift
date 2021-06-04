//
//  ErrorPresenter.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 4/29/21.
//

import UIKit

enum ErrorPresenter {
    
    static func showError(message: String, on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil) {
        
        weak var weakController = viewController
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: dismissAction)
            alert.addAction(action)
            weakController?.present(alert, animated: true, completion: nil)
        }
    }
}
// Retain Cycle - ARC (Automatic Reference Counting)
