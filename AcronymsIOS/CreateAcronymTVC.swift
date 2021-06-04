//
//  CreateAcronymTVC.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/1/21.
//

import UIKit

protocol CreateAcronymTVCDelegate: AnyObject {
    func acronymsDidUpdated(vc: CreateAcronymTVC, acronym: Acronym)
}

class CreateAcronymTVC: UITableViewController {
   
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shortTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    
    weak var delegate: CreateAcronymTVCDelegate?
    var acronym: Acronym?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let acronym = acronym {
            navigationItem.title = "Update Acronym"
            shortTextField.text = acronym.short
            longTextField.text = acronym.long
            saveButton.title = "Update"
        }
        
    }
    
    deinit {
        print("CreateAcronymTVC is successfully deleted from memory!")
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let shortText = shortTextField.text, !shortText.isEmpty else {
            ErrorPresenter.showError(message: "You must specify an Acronym", on: self)
            return
        }
        
        guard let longText = longTextField.text, !longText.isEmpty else {
            ErrorPresenter.showError(message: "You must specify a Meaning", on: self)
            return
        }
         
        let newAronym = Acronym(short: shortText, long: longText)
        
        if let acronym = acronym {
            updateAcronym(id: acronym.id, acronym: newAronym)
        } else {
            updateAcronym(acronym: newAronym)
        }
    }
    
    func updateAcronym(id: String? = nil, acronym: Acronym) {
        
        ServiceLayer.request(router: id == nil ? .createAcronym(acronym: acronym): .updateAcronym(id: id!, acronym: acronym)) { [weak self] (result: Result<Acronym, RequestError>) in
            switch result {
            case .failure(let error):
                if let weakSelf = self {
                    ErrorPresenter.showError(message: error.localizedDescription, on: weakSelf)
                }
            case .success(let acronym):
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.delegate?.acronymsDidUpdated(vc: weakSelf, acronym: acronym)
                    }
                }
            }
        }
        
    }
    
}
