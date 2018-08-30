//
//  Helpers.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar (Accenture) on 8/20/18.
//  Copyright © 2018 Gispert Pelaez, Othmar (Accenture). All rights reserved.
//

import Foundation
import UIKit

var Action = UIAlertAction.self
typealias buttonAction = ()->()

func createAlert(title: String, message: String, buttonTitle: String? = "Ok", okAction: buttonAction?) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okButtonAction = Action.init(title: buttonTitle, style: .default, handler: { action in
        
        if let ok = okAction {
            ok()
        }
    })
    
    alertController.addAction(okButtonAction)
    
    return alertController
}

func phoneNumberFormater(number:String) -> String {
    let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let numbersOnly = NSMutableString(string: cleanPhoneNumber)
    numbersOnly.insert("-", at: 3)
    numbersOnly.insert("-", at: 7)
    return numbersOnly as String
}
