//
//  APIError.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

enum APIError: Error {
    case httpError(statusCode: Int)
    case noData
    case decodingError(Error)
}
