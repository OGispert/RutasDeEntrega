//
//  RutasDetailViewController.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RutasDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    static func getInstance() -> RutasDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "RouteDetailsID") as! RutasDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let latOrigen = Route.latitudeOrigen, let lonOrigen = Route.longitudeOrigen, let latDestino = Route.latitudeDestino, let lonDestino = Route.longitudeDestino else { return }
        
        let sourceLocation = CLLocationCoordinate2D(latitude: latOrigen, longitude: lonOrigen)
        let destinationLocation = CLLocationCoordinate2D(latitude: latDestino, longitude: lonDestino)
        DispatchQueue.main.async {
            self.showRouteOnMap(pickupCoordinate: sourceLocation, destinationCoordinate: destinationLocation)
            
        }
        //32.927889, longitude: -97.011527
        //32.902514, longitude: -96.962818
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        closeView()
    }
    
    @IBAction func deleteRouteButtonTapped(_ sender: UIButton) {
        confirmDeletion()
    }
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmDeletion() {
        let alert = UIAlertController(title: "Eliminar Ruta", message: "¿Seguro que desea eliminar esta ruta?", preferredStyle: .alert)
        
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
        guard let ruta = Route.name else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ruta")
        
        fetchRequest.predicate = NSPredicate(format: "route = %@", ruta)
        
        do {
            if let routes = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for route in routes {
                    managedContext.delete(route)
                }
            }
            try managedContext.save()
            let alertController = createAlert(title: "Ruta Eliminada" , message: "Presione OK para regresar a la lista de rutas.", okAction: closeView)
            present(alertController, animated: true, completion: nil)
        } catch let error {
            let alertController = createAlert(title: "Ocurrió un Error" , message: error.localizedDescription, okAction: nil)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
