//
//  SessionService.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

class SessionService {

    static let shared = SessionService()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
    }

    // MARK: - Public API

    func fetchSessions(completion: @escaping (Result<[Session], Error>) -> Void) {
        guard let url = URL(string: "https://mock.api/api/sessions") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let request = URLRequest(url: url)

        performRequest(request, responseType: [Session].self, delay: 1, completion: completion)
    }

    func createSession(title: String, category: Category, completion: @escaping (Result<Session, Error>) -> Void) {
        guard let url = URL(string: "https://mock.api/api/sessions") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "title": title,
            "category": category.rawValue
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        performRequest(request, responseType: Session.self, completion: completion)
    }

    // MARK: - Private Methods

    private func performRequest<T: Decodable>(
        _ request: URLRequest,
        responseType: T.Type,
        delay: TimeInterval = 0,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.badServerResponse)))
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

}
