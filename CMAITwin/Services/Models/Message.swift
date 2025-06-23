//
//  Message.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let text: String
    let sender: Sender
    let timestamp: Date
}

enum Sender: String, Codable {
    case user
    case ai
}
