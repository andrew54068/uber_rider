//
//  ViewController.swift
//  uber rider
//
//  Created by kidnapper on 22/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    private let RIDER_SEGUE = "RiderVC"

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func EmailTouched(_ sender: Any) {
        self.emailTextField.text! = ""
    }
    
    @IBAction func PasswordTouched(_ sender: Any) {
        self.passwordTextField.text! = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.text! = "rider@mail.com"
        self.passwordTextField.text! = "123456"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logIn(_ sender: Any) {
        
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil{
                    self.alerTheUser(title: "Problem With Authentication", message: message!)
                }else {
                    print("login completed")
                    UberHandler.Instance.rider = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }else {
            self.alerTheUser(title: "Email and Password are Required", message: "Please enter email and password in the text fields")
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != ""{
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil{
                    self.alerTheUser(title: "Problem With Create A New User", message: message!)
                }else{
                    
                    print("CREATE USER COMPLETED")
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }
    }
    
    private func alerTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

