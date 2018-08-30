//
//  RutasViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import CoreData

class RutasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rutasTableView: UITableView!
    
    var routes: [NSManagedObject] = []
    
    static func getInstance() -> RutasViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "RoutesID") as! RutasViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rutas"
        
        enableLargeTitles()
        
        rutasTableView.delegate = self
        rutasTableView.dataSource = self
        
        rutasTableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Agregar Ruta", style: .plain, target: self, action: #selector(addNewRouteButtonTapped))
        getRoutesList()
    }
    
    @objc func addNewRouteButtonTapped() {
        let alert = UIAlertController(title: "Agregar una nueva ruta", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Guardar", style: .default) { (alertAction) in
            let nameTextField = alert.textFields![0] as UITextField
            let latitudOrigenTextField = alert.textFields![1] as UITextField
            let longitudOrigenTextField = alert.textFields![2] as UITextField
            let latitudDestinoTextField = alert.textFields![3] as UITextField
            let longitudDestinoTextField = alert.textFields![4] as UITextField
            
            guard let name = nameTextField.text,
                let latitudOrigen = latitudOrigenTextField.text?.doubleValue,
                let longitudOrigen = longitudOrigenTextField.text?.doubleValue,
                let latitudDestino = latitudDestinoTextField.text?.doubleValue,
                let longitudDestino = longitudDestinoTextField.text?.doubleValue else { return }
            self.addRoute(name, latitudOrigen, longitudOrigen, latitudDestino, longitudDestino)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nombre"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
        }
        
        alert.addTextField { (latitudeOrigenField) in
            latitudeOrigenField.placeholder = "Latitud Origen"
            latitudeOrigenField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addTextField { (longitudeOrigenField) in
            longitudeOrigenField.placeholder = "Longitud Origen"
            longitudeOrigenField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addTextField { (latitudeDestinoField) in
            latitudeDestinoField.placeholder = "Latitud Destino"
            latitudeDestinoField.keyboardType = .numbersAndPunctuation
        }
        
        alert.addTextField { (longitudeDestinoField) in
            longitudeDestinoField.placeholder = "Longitud Destino"
            longitudeDestinoField.keyboardType = .numbersAndPunctuation
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let route = routes[indexPath.row]
        
        if let cell = rutasTableView.dequeueReusableCell(withIdentifier: "RutasCell") {
            cell.textLabel?.text = route.value(forKeyPath: "route") as? String
            return cell
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = routes[indexPath.row]
        Route.name = route.value(forKeyPath: "route") as? String
        Route.latitudeOrigen = route.value(forKeyPath: "latOrigen") as? Double
        Route.longitudeOrigen = route.value(forKey: "lonOrigen") as? Double
        Route.latitudeDestino = route.value(forKeyPath: "latDestino") as? Double
        Route.longitudeDestino = route.value(forKey: "lonDestino") as? Double
        let routeDetails = RutasDetailViewController.getInstance()
        self.navigationController?.present(routeDetails, animated: true, completion: {
            guard let ruta = Route.name else { return }
            routeDetails.titleLabel.text = "Ruta " + ruta
        })
    }
    
    func addRoute(_ name: String, _ latitudOrigen: Double, _ longitudOrigen: Double, _ latitudDestino: Double, _ longitudDestino: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Ruta", in: managedContext)!
        let route = NSManagedObject(entity: entity, insertInto: managedContext)
        
        route.setValue(name, forKeyPath: "route")
        route.setValue(latitudOrigen, forKey: "latOrigen")
        route.setValue(longitudOrigen, forKey: "lonOrigen")
        route.setValue(latitudDestino, forKey: "latDestino")
        route.setValue(longitudDestino, forKey: "lonDestino")
        
        do {
            try managedContext.save()
            getRoutesList()
            let alertController = createAlert(title: "Nueva Ruta" , message: "Se ha agregado una nueva ruta a la lista.", okAction: nil)
            present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func getRoutesList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Ruta")
        
        do {
            routes = try managedContext.fetch(fetchRequest)
            self.rutasTableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
