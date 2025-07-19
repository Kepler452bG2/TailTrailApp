//
//  User.swift
//  TailTrail
//
//  Created by Shepard on 30.06.2025.
//

import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var email: String
    var phone: String?
    var createdAt: Date?
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case createdAt = "created_at"
        case imageUrl = "image_url"
    }
} 