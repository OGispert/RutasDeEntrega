//
//  Models.swift
//  RutasDeEntrega
//
//  Created by Gispert Pelaez, Othmar on 8/20/18.
//  Copyright © 2018 Gispert Pelaez, Othmar. All rights reserved.
//

import Foundation

struct User {
    static var name: String?
    static var email: String?
    static var username: String?
    static var password: String?
}

struct Driver {
    static var name: String?
    static var phoneNumber: String?
    static var assignedRoute: String?
}

struct Route {
    static var name: String?
    static var longitudeOrigen: Double?
    static var latitudeOrigen: Double?
    static var longitudeDestino: Double?
    static var latitudeDestino: Double?
}
