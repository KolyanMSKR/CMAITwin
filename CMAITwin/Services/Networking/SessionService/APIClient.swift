//
//  APIClient.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

import Foundation

final class APIClient {

    static let shared = APIClient()
    private let session: URLSession
    private let decoder: JSONDecoder

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func send<R: APIRequest>(
        _ request: R,
        completion: @escaping (Result<R.Response, Error>) -> Void
    ) {
        let urlRequest = request.urlRequest
        let task = session.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard
                    let http = response as? HTTPURLResponse,
                    (200..<300).contains(http.statusCode)
                else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(APIError.httpError(statusCode: code)))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }

                do {
                    let decoded = try self.decoder.decode(R.Response.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(APIError.decodingError(error)))
                }
            }
        }
        task.resume()
    }

}
