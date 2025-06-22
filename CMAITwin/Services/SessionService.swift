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

    // MARK: - API's methods

    func fetchSessions(completion: @escaping (Result<[Session], Error>) -> Void) {
        guard let url = URL(string: "https://mock.api/api/sessions") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let sessions = try decoder.decode([Session].self, from: data)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        completion(.success(sessions))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func createSession(title: String, category: Category, completion: @escaping (Result<Session, Error>) -> Void) {
        let newSession = Session(
            id: Int.random(in: 100...999),
            date: Date(),
            title: title,
            category: category,
            summary: "Mock summary for session."
        )

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(.success(newSession))
        }
    }

}
