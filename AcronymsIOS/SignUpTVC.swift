//
//  SignUpTVC.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/8/21.
//

import UIKit

class SignUpTVC: UITableViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func signUpPressed(_ sender: Any) {
        guard let usernameText = usernameTextField.text, !usernameText.isEmpty else {
            ErrorPresenter.showError(message: "All fields are required", on: self)
            return
        }
        
        guard let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            ErrorPresenter.showError(message: "All fields are required", on: self)
            return
        }
        
        guard let rePasswordText = rePasswordTextField.text, rePasswordText == passwordText else {
            ErrorPresenter.showError(message: "Passwords do not match", on: self)
            return 
        }
        
        let newUser = User(username: usernameText, password: passwordText)
        
        ServiceLayer.request(router: .signup(user: newUser)) { (result: Result<PublicUser, RequestError>) in
            switch result {
            case .failure:
                ErrorPresenter.showError(message: "Sorry, we couldn't sign you up. Please try later", on: self)
            case .success:
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
