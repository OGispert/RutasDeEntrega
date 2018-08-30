//
//  ChoferesViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import CoreData

class ChoferesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var choferesTableView: UITableView!
    
    var drivers: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Choferes"
        enableLargeTitles()
        
        choferesTableView.delegate = self
        choferesTableView.dataSource = self
        
        choferesTableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Agregar Chofer", style: .plain, target: self, action: #selector(addNewDriverButtonTapped))
        
        getDriversList()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let driver = drivers[indexPath.row]
        
        if let cell = choferesTableView.dequeueReusableCell(withIdentifier: "DriversCell") {
            cell.textLabel?.text = driver.value(forKeyPath: "name") as? String
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let driver = drivers[indexPath.row]
        Driver.name = driver.value(forKeyPath: "name") as? String
        Driver.phoneNumber = driver.value(forKeyPath: "phone") as? String
        Driver.assignedRoute = driver.value(forKey: "route") as? String
        let driverDetails = ChoferesDetailViewController.getInstance()
        self.navigationController?.present(driverDetails, animated: true, completion: nil)
    }
    
    @objc func addNewDriverButtonTapped() {
        let alert = UIAlertController(title: "Agregar un nuevo chofer", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Guardar", style: .default) { (alertAction) in
            let nameTextField = alert.textFields![0] as UITextField
            let phoneTextField = alert.textFields![1] as UITextField
            
            guard let name = nameTextField.text, let phoneNumber = phoneTextField.text else { return }
            self.save(name, phoneNumber)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nombre"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        }
        
        alert.addTextField { (phoneField) in
            phoneField.delegate = self
            phoneField.placeholder = "Teléfono"
            phoneField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
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
    
    func save(_ name: String, _ phoneNumber: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Chofer", in: managedContext)!
        let driver = NSManagedObject(entity: entity, insertInto: managedContext)
        
        driver.setValue(name, forKeyPath: "name")
        driver.setValue(phoneNumber, forKey: "phone")
        
        do {
            try managedContext.save()
            getDriversList()
            let alertController = createAlert(title: "Nuevo Chofer" , message: "Se ha agregado un nuevo chofer a la lista.", okAction: nil)
            present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func getDriversList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Chofer")
        
        do {
            drivers = try managedContext.fetch(fetchRequest)
            self.choferesTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}
