//
//  LoginTVC.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/8/21.
//

import UIKit
import AuthenticationServices

class LoginTVC: UITableViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let siwaCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) else {
            fatalError("Unable to find a SignInWithApple cell.")
        }
        
        let button = ASAuthorizationAppleIDButton()
        
        button.frame = CGRect(x: (view.frame.width - 250) / 2, y: 3, width: 250, height: 38)
        
        button.addTarget(self, action: #selector(handleSignInWithApple), for: .touchUpInside)
        
        siwaCell.contentView.addSubview(button)
    }
    

    @IBAction func loginWithGooglePressed(_ sender: Any) {
        guard let url = Router.googleLogin.url else {
            return
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "acronymsApp") { (callBackURL, error) in
            guard error == nil, let callBackURL = callBackURL else { return }
            
            let queryItems = URLComponents(string: callBackURL.absoluteString)?.queryItems
            let token = queryItems?.first { $0.name == "token"}?.value
            Auth.shared.login(token: token!)
        }
        
        session.presentationContextProvider = self
        session.start()
        
        
    }
    @IBAction func loginPressed(_ sender: Any) {
        guard let usernameText = usernameTextField.text, !usernameText.isEmpty else {
            ErrorPresenter.showError(message: "All fields are required", on: self)
            return
        }
        
        guard let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            ErrorPresenter.showError(message: "All fields are required", on: self)
            return
        }
        
        ServiceLayer.request(router: .login(username: usernameText, password: passwordText)) { (result: Result<Token, RequestError>) in
            switch result {
            case .failure(let error):
                ErrorPresenter.showError(message: error.localizedDescription, on: self)
            case .success(let token):
                Auth.shared.login(token: token.value)
                // Go To AcronymsViewController
            }
        }
    }
    
    @objc func handleSignInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email] //запрос данных
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self //где наш controller должен показываться
        authController.performRequests()
    }
}

extension LoginTVC: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let window = view.window else {
            fatalError("No window can be found")
        }
        
        return window
    }    
    
}

extension LoginTVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            fatalError("No window can be found")
        }
        
        return window
    }
    
    
}

extension LoginTVC: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let identityToken = credential.identityToken, let tokenString = String(data: identityToken, encoding: .utf8) else {
                print("Failed to get identityToken from credential")
                
                return
            }
            
            let siwaToken = SigninWithAppleToken(token: tokenString, name: credential.email)
            
            ServiceLayer.request(router: .appleLogin(siwaToken: siwaToken)) { (result: Result<Token, RequestError>) in
                switch result {
                case .failure(let error):
                    ErrorPresenter.showError(message: error.localizedDescription, on: self)
                case .success(let token):
                    Auth.shared.login(token: token.value)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        ErrorPresenter.showError(message: error.localizedDescription, on: self)
    }
}

struct Token: Codable {
    let value: String
}

struct SigninWithAppleToken: Codable {
    let token: String
    let name: String?
}
