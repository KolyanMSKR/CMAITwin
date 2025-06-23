//
//  APIRequest.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

// MARK: - Protocol APIRequest

protocol APIRequest {
    associatedtype Response: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

// MARK: - extension APIRequest

extension APIRequest {

    var baseURL: URL { URL(string: "https://mock.api")! }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var body: Data? { nil }

    var urlRequest: URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        return request
    }

}
