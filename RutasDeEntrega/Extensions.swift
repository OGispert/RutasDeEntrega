//
//  Extensions.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/19/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    
    func makeNavigationBarClear() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = nil
        self.navigationBar.backgroundColor = nil
        self.navigationBar.isTranslucent = true
        self.navigationBar.clipsToBounds = true
    }
}

extension UIViewController {
    
    @objc func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        becomeFirstResponder()
        view.endEditing(true)
    }
    
    func enableLargeTitles() {
        if #available(iOS 11, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    func disableLargeTitles() {
        if #available(iOS 11, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    var doubleValue: Double {
        return Double(self) ?? 0
    }
}
