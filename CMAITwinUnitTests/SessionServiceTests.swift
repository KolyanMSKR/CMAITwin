//
//  SessionServiceTests.swift
//  CMAITwin
//
//  Created by Anderen on 23.06.2025.
//


import XCTest
@testable import CMAITwin

final class SessionServiceTests: XCTestCase {

    func testFetchSessions_Success() {
        let mockClient = MockAPIClient()
        let expectedSessions = [
            Session(id: 1, date: Date(), title: "Test", category: .career, summary: "Summary")
        ]
        mockClient.fetchSessionsResult = .success(expectedSessions)

        let service = SessionService(client: mockClient)
        let expectation = self.expectation(description: "FetchSessions")

        service.fetchSessions { result in
            switch result {
            case .success(let sessions):
                XCTAssertEqual(sessions, expectedSessions)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCreateSession_Failure() {
        let mockClient = MockAPIClient()
        let expectedError = NSError(domain: "Test", code: 123, userInfo: nil)
        mockClient.createSessionResult = .failure(expectedError)

        let service = SessionService(client: mockClient)
        let expectation = self.expectation(description: "CreateSession")

        service.createSession(title: "Failing", category: .other) { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error as NSError):
                XCTAssertEqual(error, expectedError)
            default:
                XCTFail("Unexpected error type")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchMessages_Success() {
        let mockClient = MockAPIClient()
        let expectedMessages = [
            Message(id: UUID(), text: "Hello", sender: .ai, timestamp: Date())
        ]
        mockClient.fetchMessagesResult = .success(expectedMessages)

        let service = SessionService(client: mockClient)
        let expectation = self.expectation(description: "FetchMessages")

        service.fetchMessages(for: 42) { result in
            switch result {
            case .success(let messages):
                XCTAssertEqual(messages, expectedMessages)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
