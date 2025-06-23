//
//  MockAPIClient.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//

@testable import CMAITwin
import Foundation

final class MockAPIClient: APIClientProtocol {

    var fetchSessionsResult: Result<[Session], Error>?
    var createSessionResult: Result<Session, Error>?
    var fetchMessagesResult: Result<[Message], Error>?

    func send<R>(_ request: R, completion: @escaping (Result<R.Response, Error>) -> Void) where R: APIRequest {
        switch request {
        case is FetchSessionsRequest:
            completion(fetchSessionsResult as! Result<R.Response, Error>)
        case is CreateSessionRequest:
            completion(createSessionResult as! Result<R.Response, Error>)
        case is FetchMessagesRequest:
            completion(fetchMessagesResult as! Result<R.Response, Error>)
        default:
            fatalError("Unexpected request type: \(type(of: request))")
        }
    }

}
