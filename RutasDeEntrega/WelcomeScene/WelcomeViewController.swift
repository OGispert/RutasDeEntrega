//
//  ViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import CoreData

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    static func getInstance() -> WelcomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "WelcomeID") as! WelcomeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTextField.delegate = self
        passwordTextField.delegate = self
        self.navigationController?.makeNavigationBarClear()
        
        loginButton.isEnabled = false
        
        hideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userTextField.text = ""
        passwordTextField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            guard let passwordCount = self.passwordTextField.text?.count else { return }
            let isValidUsername = self.userTextField.text?.count == 0
            
            if isValidUsername || passwordCount < 8 {
                self.loginButton.isEnabled = false
            } else {
                self.loginButton.isEnabled = true
            }
        }
        return true
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let username = userTextField.text, let password = passwordTextField.text else { return }
        validateUser(username: username, password: password)
    }
    
    @IBAction func newUserButtonTapped(_ sender: UIButton) {
        let newUser = NewUserViewController.getInstance()
        self.navigationController?.pushViewController(newUser, animated: true)
    }
    
    func validateUser(username: String, password: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Usuario")
        
        do {
            let users = try managedContext.fetch(fetchRequest)
            for user in users as [NSManagedObject] {
                if user.value(forKey: "username") as! String == username && user.value(forKey: "password") as! String == password {
                    User.name = user.value(forKey: "nombre") as? String
                    User.email = user.value(forKey: "email") as? String
                    User.username = username
                    User.password = password
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarView = storyboard.instantiateViewController(withIdentifier: "MainTabBarID") as! UITabBarController
                    tabBarView.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(tabBarView, animated: true)
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

