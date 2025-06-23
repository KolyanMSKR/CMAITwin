//
//  CreateSessionRequest.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

struct CreateSessionRequest: APIRequest {
    typealias Response = Session
    let title: String
    let category: Category

    var path: String { "/api/sessions" }
    var method: HTTPMethod { .post }
    var body: Data? {
        try? JSONEncoder().encode(["title": title, "category": category.rawValue])
    }
}
