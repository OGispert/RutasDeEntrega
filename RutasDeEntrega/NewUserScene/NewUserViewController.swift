//
//  NewUserViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar. All rights reserved.
//

import UIKit
import CoreData

class NewUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    
    static func getInstance() -> NewUserViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "NewUserID") as! NewUserViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate =  self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        createUserButton.isEnabled = false
        
        hideKeyboard()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            guard let passwordCount = self.passwordTextField.text?.count else { return }
            let isValidName = self.nameTextField.text?.count == 0
            let isValidUsername = self.usernameTextField.text?.count == 0
            let password = self.passwordTextField.text
            let confirmPassword = self.confirmPasswordTextField.text
            
            if isValidName || isValidUsername || passwordCount < 8 || password != confirmPassword || self.emailTextField.text?.isValidEmail() == false {
                self.createUserButton.isEnabled = false
            } else {
                self.createUserButton.isEnabled = true
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -150, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -150, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @IBAction func createUserButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text else { return }
        validateUsername(username)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        clearAllFields()
    }
    
    func goToLogin() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func clearAllFields() {
        nameTextField.text = ""
        emailTextField.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    func save(name: String, email: String, username: String, password: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Usuario", in: managedContext)!
        
        let user = NSManagedObject(entity: entity, insertInto: managedContext)
        
        user.setValue(name, forKeyPath: "nombre")
        user.setValue(email, forKey: "email")
        user.setValue(username, forKey: "username")
        user.setValue(password, forKey: "password")
        
        do {
            try managedContext.save()
            let alertController = createAlert(title: "RDE_RegistrationCompleted".localizedString(), message: "RDE_OkToLogin".localizedString(), okAction: goToLogin)
            present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func validateUsername(_ username: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Usuario")
        
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        
        do {
            let selectedUsername = try managedContext.fetch(fetchRequest)
            if selectedUsername.count == 0 {
                guard let name = nameTextField.text, let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text else { return }
                
                save(name: name, email: email, username: username, password: password)
            } else {
                let alertController = createAlert(title: "RDE_UserAlreadyExists_Title".localizedString(), message: "RDE_UserAlreadyExists_Message".localizedString(), okAction: changeUsername)
                present(alertController, animated: true, completion: nil)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func changeUsername() {
        usernameTextField.text = ""
        usernameTextField.becomeFirstResponder()
    }
}
