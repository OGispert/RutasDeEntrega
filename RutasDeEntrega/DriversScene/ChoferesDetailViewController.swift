//
//  ChoferesDetailViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ChoferesDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var assignRouteButton: UIButton!
    @IBOutlet weak var routesPicker: UIPickerView!
    
    var routes: [NSManagedObject] = []
    
    static func getInstance() -> ChoferesDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "DriverDetailsID") as! ChoferesDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        routesPicker.delegate = self
        routesPicker.dataSource = self
        
        getRoutesList()
        
        nameLabel.text = Driver.name
        
        if let phoneNumber = Driver.phoneNumber {
            phoneLabel.text = phoneNumberFormater(number: phoneNumber)
        }
        
        if let route = Driver.assignedRoute, route != "" {
            assignRouteButton.setTitle("RDE_AssignedRoute".localizedString() + route, for: .normal)
        }
        
        if routes.count == 0 {
            assignRouteButton.isEnabled = false
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return routes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let route = routes[row]
        return route.value(forKeyPath: "route") as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let route = routes[row]
        guard let ruta = route.value(forKeyPath: "route") as? String else { return }
        verifyRouteIsAvailable(ruta)
        updateDriverRoute(ruta)
        routesPicker.isHidden = true
    }
    
    @IBAction func assignRouteButtonTapped(_ sender: UIButton) {
        routesPicker.isHidden = false
    }
    
    @IBAction func editName(_ sender: UIButton) {
        editNameButtonTapped()
    }
    
    @IBAction func editPhoneNumber(_ sender: UIButton) {
        editPhoneNumberButtonTapped()
    }
    
    @IBAction func deleteDriverButtonTapped(_ sender: UIButton) {
        confirmDeletion()
    }
    
    @IBAction func closeDetailsView(_ sender: UIButton) {
        closeView()
    }
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func editNameButtonTapped() {
        let alert = UIAlertController(title: "RDE_EditarNombre".localizedString(), message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "RDE_Guardar".localizedString(), style: .default) { (alertAction) in
            let nameTextField = alert.textFields![0] as UITextField
            
            if let name = nameTextField.text, name.count != 0 {
                self.updateDriverName(name)
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "RDE_Nombre".localizedString()
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        }
        
        let cancelAction = UIAlertAction(title: "RDE_Cancelar".localizedString(), style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func editPhoneNumberButtonTapped() {
        let alert = UIAlertController(title: "RDE_EditarTelefono".localizedString(), message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "RDE_Guardar".localizedString(), style: .default) { (alertAction) in
            let phoneTextField = alert.textFields![0] as UITextField
            
            if let phoneNumber = phoneTextField.text, phoneNumber.count == 10  {
                self.updateDriverPhoneNumber(phoneNumber)
            }
        }
        
        alert.addTextField { (phoneField) in
            phoneField.delegate = self
            phoneField.placeholder = "RDE_Telefono".localizedString()
            phoneField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "RDE_Cancelar".localizedString(), style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldCount = textField.text?.count ?? 0
        let newLength = textFieldCount - range.length + string.count
        
        if newLength > 10 {
            return false
        }
        return true
    }
    
    func updateDriverPhoneNumber(_ phoneNumber: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let name = Driver.name else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(phoneNumber, forKey: "phone")
            }
            try managedContext.save()
            Driver.phoneNumber = phoneNumber
            phoneLabel.text = phoneNumberFormater(number: phoneNumber)
        } catch {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateDriverName(_ name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let phoneNumber = Driver.phoneNumber else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        fetchRequest.predicate = NSPredicate(format: "phone = %@", phoneNumber)
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(name, forKey: "name")
            }
            try managedContext.save()
            Driver.name = name
            nameLabel.text = name
        } catch {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateDriverRoute(_ route: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let name = Driver.name else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(route, forKey: "route")
            }
            try managedContext.save()
            assignRouteButton.setTitle("RDE_AssignedRoute".localizedString() + route, for: .normal)
        } catch {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func deleteUser() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let name = Driver.name else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            if let drivers = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for driver in drivers {
                    managedContext.delete(driver)
                }
            }
            try managedContext.save()
            let alertController = createAlert(title: "RDE_DriverDeleted_AlertTitle".localizedString(), message: "RDE_DriverDeleted_AlertMessage".localizedString(), okAction: closeView)
            present(alertController, animated: true, completion: nil)
        } catch let error {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func confirmDeletion() {
        let alert = UIAlertController(title: "RDE_ConfirmDriverDeletion_Title".localizedString(), message: "RDE_ConfirmDriverDeletion_Title".localizedString(), preferredStyle: .alert)
        
        let action = UIAlertAction(title: "RDE_Eliminar".localizedString(), style: .destructive) { (alertAction) in
            self.deleteUser()
        }
        let cancelAction = UIAlertAction(title: "RDE_Cancelar".localizedString(), style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func getRoutesList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Ruta")
        
        do {
            routes = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func verifyRouteIsAvailable(_ route: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            for result in results! {
                if route == result.value(forKey: "route") as? String {
                    let alertController = createAlert(title: "RDE_Atencion".localizedString(), message: "RDE_RoutePreviousyAssigned".localizedString(), okAction: nil)
                    present(alertController, animated: true, completion: nil)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: SMS Methods
    
    @IBAction func sendText(sender: UIButton) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            guard let route = Driver.assignedRoute, route != "" else { return }
            controller.messageComposeDelegate = self
            controller.body = String(format: "RDE_SMS_Message".localizedString(), route)
            controller.recipients = [phoneLabel.text] as? [String]
            self.present(controller, animated: true, completion: nil)
        } else {
            let alertController = createAlert(title: "RDE_Error".localizedString(), message: "", okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}
