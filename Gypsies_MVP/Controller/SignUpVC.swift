//
//  SignUpVC.swift
//  Gypsies_MVP
//
//  Created by M on 2020/01/13.
//  Copyright © 2020 筒井知生. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper
import FirebaseAuth


class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImagePicker: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    var userUid: String!
    
    var emailField: String!
    
    var passwordField: String!
    
    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()

        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            
            performSegue(withIdentifier: "toMessage", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            userImagePicker.image = image
            
            imageSelected = true
            
        } else {
            
            print("image wasnt selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUser(img: String) {
        
        let userData = [
        "username": username!,
        "userImg": img
        ]
    
        KeychainWrapper.standard.set(userUid, forKey: "uid")
        
        let location = Database.database().reference().child("users").child(userUid)
        
        location.setValue(userData)
        
        dismiss(animated: true, completion: nil)
    
    }
    
    func uploadImg() {
        
        if usernameField.text == nil {
            
            signUpBtn.isEnabled = false
        } else {
            
            username = usernameField.text
            
            signUpBtn.isEnabled = true
        }
        
        guard let img = userImagePicker.image, imageSelected == true else {
            
            print("image needs to be selected")
            
            return
        }
        
        if let imgData = img.jpegData(compressionQuality: 0.2) {

            let imgUid = NSUUID().uuidString

            let metadata = StorageMetadata()

            metadata.contentType = "image/jpeg"

//            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
//
//                if error != nil {
//
//                    print("did not upload img")
//                } else {
//
//                    print("uploaded")
//
//                    let downloadURL = metadata?.downloadURL().absoluteString
//
//                    if let url = downloadURL {
//
//                        self.setUser(img: url)
//                    }
//                }
//            }
        }
    }

    @IBAction func createAccount (_ sender: AnyObject) {
        
        Auth.auth().createUser(withEmail: emailField, password: passwordField,
            completion: { (user, error) in
            
                if error != nil {
                    
                    print("Cant create user")
                } else {
                    
                    if let user = user {
                        
                        self.userUid = user.user.uid
                    }
                }
                
                self.uploadImg()
        })
    }
    
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel (_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }

}
