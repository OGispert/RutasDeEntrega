//
//  AjustesViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import CoreData

class AjustesViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ajustes"
        enableLargeTitles()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        settingsTableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let resetRoutesCell = settingsTableView.dequeueReusableCell(withIdentifier: "ButtonCell") {
                resetRoutesCell.textLabel?.text = "Borrar rutas asignadas"
                resetRoutesCell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                return resetRoutesCell
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let signOutCell = settingsTableView.dequeueReusableCell(withIdentifier: "ButtonCell") {
                    signOutCell.textLabel?.text = "Salir"
                    signOutCell.textLabel?.textColor =  #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                    return signOutCell
                }
            case 1:
                if let editUserCell = settingsTableView.dequeueReusableCell(withIdentifier: "ButtonCell") {
                    editUserCell.textLabel?.text = "Cambiar Contraseña"
                    editUserCell.textLabel?.textColor =  #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                    return editUserCell
                }
            case 2:
                if let deleteUserCell = settingsTableView.dequeueReusableCell(withIdentifier: "ButtonCell") {
                    deleteUserCell.textLabel?.text = "Borrar mi usuario"
                    deleteUserCell.textLabel?.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                    return deleteUserCell
                }
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            resetRoutesSelection()
        case 1:
            switch indexPath.row {
            case 0:
                signOut()
            case 1:
                editPasswordCellTapped()
            case 2:
                confirmDeletion()
            default :
                return
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Rutas y Choferes"
        case 1:
            return "Usuario"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            guard let name = User.name, let username = User.username, let email = User.email else { return "" }
            return "Nombre: " + name + "\n" + "Usuario: " + username + "\n" + "Email: " + email
        default:
            return ""
        }
    }
    
    func signOut() {
        if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            let welcomeVC = WelcomeViewController.getInstance()
            rootNav.setViewControllers([welcomeVC], animated: true)
        }
    }
    
    func editPasswordCellTapped() {
        let alert = UIAlertController(title: "Cambiar Contraseña", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Actualizar", style: .default) { (alertAction) in
            let passwordTextField = alert.textFields![0] as UITextField
            
            if let password = passwordTextField.text, password.count >= 8 {
                self.updateUserPassword(password)
            }
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nueva Contraseña"
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func updateUserPassword(_ password: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let name = User.name else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        
        fetchRequest.predicate = NSPredicate(format: "nombre = %@", name)
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                results![0].setValue(password, forKey: "password")
            }
            try managedContext.save()
            let alertController = createAlert(title: "Contraseña Actualizada" , message: "Presione OK para salir de la aplicación y reingresar sus datos de acceso.", okAction: signOut)
            present(alertController, animated: true, completion: nil)
        } catch {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func confirmDeletion() {
        guard let username = User.username else { return }
        let alert = UIAlertController(title: "Eliminar Usuario", message: "¿Seguro que desea eliminar al usuario " + username + "?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Eliminar", style: .destructive) { (alertAction) in
            self.deleteUser()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func deleteUser() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let username = User.username else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Usuario")
        
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        
        do {
            if let users = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for user in users {
                    managedContext.delete(user)
                }
            }
            try managedContext.save()
            let alertController = createAlert(title: "Usuario Eliminado" , message: "Presione OK para salir de la aplicación.", okAction: signOut)
            present(alertController, animated: true, completion: nil)
        } catch let error {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func resetRoutesSelection() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chofer")
        
        do {
            if let drivers = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for driver in drivers {
                    driver.setValue("", forKey: "route")
                }
            }
            try managedContext.save()
            Driver.assignedRoute = ""
            let alertController = createAlert(title: "Rutas Borradas" , message: "La selección de rutas fue borrada con éxito.", okAction: nil)
            present(alertController, animated: true, completion: nil)
            
        } catch {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
}
