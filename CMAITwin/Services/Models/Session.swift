//
//  Session.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

struct Session: Identifiable, Codable, Equatable {
    let id: Int
    let date: Date
    let title: String
    let category: Category
    let summary: String
}
