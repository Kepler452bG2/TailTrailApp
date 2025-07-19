//
//  User.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let name: String?
    let email: String
    let phone: String?
    let createdAt: String
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone
        case createdAt = "created_at"
        case imageUrl = "image_url"
    }
} 