//
//  UserInfoTVC.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/19/21.
//

import UIKit

class UserInfoTVC: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: PublicUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ServiceLayer.request(router: .getUserInfo) { [weak self] (result: Result<PublicUser, RequestError>) in
            switch result {
            case .failure(let error):
                if let weakSelf = self {
                    ErrorPresenter.showError(message: error.localizedDescription, on: weakSelf)
                }
            case .success(let user):
                self?.user = user
                
                if let _ = user.profileImage {
                    // if image exists on server do smth:
                    self?.profileImageView.loadImage(router: .loadImage)
                }
                
                DispatchQueue.main.async {
                    self?.usernameLabel.text = user.username
                }
            }
        }
        
    }

    @IBAction func addImagePressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // show Alert Controller -> 1. Choose from Gallery, 2. Camera
            showAlertForSource()
        } else {
            // choose from Gallery
            goToSource(.photoLibrary)
        }
    }
    
    func showAlertForSource() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let gelleryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { (_) in
            // go to gallery
            self.goToSource(.photoLibrary)
        }
        
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (_) in
            // go to camera
            self.goToSource(.camera)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(gelleryAction)
        alert.addAction(cameraAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func goToSource(_ source: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension UserInfoTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else { return } // - получили изображение
        profileImageView.image = pickedImage
        
        // send picture to server
        let image = ImageUploadData(image: pickedImage.jpegData(compressionQuality: 0.3)!)
        
        if let _ = user {
            ServiceLayer.requestToDelete(router: .uploadImage(image: image)) { [weak self] (error) in
                if let error = error {
                    if let weakSelf = self {
                        ErrorPresenter.showError(message: error.localizedDescription, on: weakSelf)
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
