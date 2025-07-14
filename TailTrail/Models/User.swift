//
//  User.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var phone: String?
} 