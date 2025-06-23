//
//  FetchSessionsRequest.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

struct FetchSessionsRequest: APIRequest {
    typealias Response = [Session]
    var path: String { "/api/sessions" }
    var method: HTTPMethod { .get }
}
