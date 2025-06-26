//
//  SendMessageRequest.swift
//  CMAITwin
//
//  Created by Anderen on 24.06.2025.
//

import Foundation

struct SendMessageRequest: APIRequest {
    typealias Response = Message

    let sessionId: Int
    let text: String

    var path: String {
        "/api/sessions/\(sessionId)/messages"
    }

    var method: HTTPMethod {
        .post
    }

    var body: Data? {
        let json = ["text": text]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return data
        } catch {
            return nil
        }
    }
}
