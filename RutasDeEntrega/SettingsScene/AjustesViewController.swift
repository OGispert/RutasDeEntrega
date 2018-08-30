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
            return 2
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
    
    func signOut() {
        if let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            let welcomeVC = WelcomeViewController.getInstance()
            rootNav.setViewControllers([welcomeVC], animated: true)
        }
    }
    
    func confirmDeletion() {
        let alert = UIAlertController(title: "Eliminar Usuario", message: "¿Seguro que desea eliminar su usuario?", preferredStyle: .alert)
        
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
