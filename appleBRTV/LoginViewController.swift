//

//  ViewController.swift
//  appleBRTV
//
//  Created by Aleksandr Kelbas on 10/10/2015.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var sessionID: String? = nil
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    var completion: (()->())? = nil
    
    @IBAction func login(_ sender: AnyObject) {
        
        
        if loginDetailsEntered(true) == false
        {
            return;
        }
        
        BRTVAPI.sharedInstance.login(usernameTextField.text!, password: passwordTextField.text!, completion: {
            [weak self](response: AnyObject?, error: Error?) in
            
            DispatchQueue.main.async(execute: {
                if (error != nil)
                {
                    let alert = UIAlertController(title: "Failed to login", message: "Please check you login details and try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                else
                {
                    if self != nil
                    {
                        let cred = URLCredential(user: self!.usernameTextField.text!, password: self!.passwordTextField.text!, persistence: .permanent)
                        URLCredentialStorage.shared.set(cred, for: Functions.getUrlProtectionSpace())
                        
                        if self!.completion != nil
                        {
                            self!.completion!()
                        }
                        
                    }
                    
                }

            })
            
    
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Helpers
    func loginDetailsEntered(_ showAlert: Bool) -> Bool
    {
        if  usernameTextField.text?.characters.count == 0 || passwordTextField.text?.characters.count == 0
        {
            let alert = UIAlertController(title: "Attention!", message: "Please enter your username and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
        else
        {
            return true
        }

    }
    
    
    // MARK: Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == passwordTextField
        {

            if loginDetailsEntered(false) == true
            {
                login(self)
            }
        }
        return true
    }
    
    
    
    

}

