//
//  FetchMessagesRequest.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

struct FetchMessagesRequest: APIRequest {
    typealias Response = [Message]
    let sessionId: Int

    var path: String { "/api/sessions/\(sessionId)/messages" }
    var method: HTTPMethod { .get }
}
