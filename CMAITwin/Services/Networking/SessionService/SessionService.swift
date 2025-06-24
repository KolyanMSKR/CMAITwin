//
//  SessionService.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

final class SessionService: ObservableObject {

    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchSessions(
        completion: @escaping (Result<[Session], Error>) -> Void
    ) {
        client.send(FetchSessionsRequest(), completion: completion)
    }

    func createSession(
        title: String,
        category: Category,
        completion: @escaping (Result<Session, Error>) -> Void
    ) {
        let request = CreateSessionRequest(title: title, category: category)
        client.send(request, completion: completion)
    }

    func fetchMessages(
        for sessionId: Int,
        completion: @escaping (Result<[Message], Error>) -> Void
    ) {
        let request = FetchMessagesRequest(sessionId: sessionId)
        client.send(request, completion: completion)
    }

}
