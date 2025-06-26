//
//  MockURLProtocol.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

class MockURLProtocol: URLProtocol {

    static var mockSessions: [Session] = [
        Session(id: 1, date: Date().addingTimeInterval(-3600), title: "Career Chat", category: .career, summary: "Talked about job goals."),
        Session(id: 2, date: Date().addingTimeInterval(-86400), title: "Feeling Stressed", category: .emotions, summary: "Discussed coping strategies."),
        Session(id: 3, date: Date().addingTimeInterval(-172_800), title: "Relationship talk", category: .productivity, summary: "Discussed communication.")
    ]

    static var messagesStorage: [Int: [Message]] = [
        1: [
            Message(id: UUID(), text: "Hi! How are you today?", sender: .ai, timestamp: Date().addingTimeInterval(-300)),
            Message(id: UUID(), text: "I'm thinking about my career goals.", sender: .user, timestamp: Date().addingTimeInterval(-240)),
            Message(id: UUID(), text: "That's great! What specific goals do you have in mind?", sender: .ai, timestamp: Date().addingTimeInterval(-180))
        ],
        2: [
            Message(id: UUID(), text: "Hello! I'm here to help with your emotions.", sender: .ai, timestamp: Date().addingTimeInterval(-400)),
            Message(id: UUID(), text: "I've been feeling really stressed lately.", sender: .user, timestamp: Date().addingTimeInterval(-350)),
            Message(id: UUID(), text: "I understand. Let's talk about some coping strategies.", sender: .ai, timestamp: Date().addingTimeInterval(-300))
        ],
        3: [
            Message(id: UUID(), text: "Hi! Ready to discuss productivity?", sender: .ai, timestamp: Date().addingTimeInterval(-500)),
            Message(id: UUID(), text: "I need help with communication in relationships.", sender: .user, timestamp: Date().addingTimeInterval(-450)),
            Message(id: UUID(), text: "Communication is key! What challenges are you facing?", sender: .ai, timestamp: Date().addingTimeInterval(-400))
        ]
    ]

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return url.host == "mock.api" && url.path.starts(with: "/api/")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        if url.path.starts(with: "/api/sessions/"), url.path.contains("/messages") {
            if request.httpMethod == "GET" {
                handleGetMessages(url: url)
            } else if request.httpMethod == "POST" {
                var bodyData: Data?

                if let body = request.httpBody {
                    bodyData = body
                } else if let stream = request.httpBodyStream {
                    bodyData = Data(reading: stream)
                } else {
                    print("MockURLProtocol: No body found in request")
                    print("MockURLProtocol: Request description: \(request)")
                }

                if let data = bodyData {
                    handlePostMessage(url: url, bodyData: data)
                } else {
                    client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                }
            } else {
                client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            }
            return
        }

        switch (url.path, request.httpMethod) {
        case ("/api/sessions", "GET"):
            handleGetSessions(url: url)

        case ("/api/sessions", "POST"):
            if let stream = request.httpBodyStream {
                let data = Data(reading: stream)
                handlePostSession(url: url, bodyData: data)
            } else if let body = request.httpBody {
                handlePostSession(url: url, bodyData: body)
            } else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            }

        default:
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
        }
    }

    override func stopLoading() {
    }

}

// MARK: - Private extension

private extension MockURLProtocol {

    private func handleGetSessions(url: URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(MockURLProtocol.mockSessions),
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: 200,
                  httpVersion: nil,
                  headerFields: ["Content-Type": "application/json"]
              )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotDecodeContentData))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func handlePostSession(url: URL, bodyData: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: String],
              let title = json["title"],
              let categoryRaw = json["category"],
              let category = Category(rawValue: categoryRaw)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotParseResponse))
            return
        }

        let newSession = Session(
            id: Int.random(in: 1000...9999),
            date: Date(),
            title: title,
            category: category,
            summary: "Mock summary for session."
        )

        MockURLProtocol.mockSessions.insert(newSession, at: 0)
        MockURLProtocol.messagesStorage[newSession.id] = [
            Message(id: UUID(), text: "Hello! I'm here to help you with \(category.rawValue.lowercased()). How can I assist you today?", sender: .ai, timestamp: Date())
        ]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(newSession),
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: 201,
                  httpVersion: nil,
                  headerFields: ["Content-Type": "application/json"]
              )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotDecodeContentData))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func handleGetMessages(url: URL) {
        let pathComponents = url.path.split(separator: "/")
        guard pathComponents.count >= 3,
              let sessionId = Int(pathComponents[2]) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        let messages = MockURLProtocol.messagesStorage[sessionId] ?? []

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard
            let data = try? encoder.encode(messages),
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotParseResponse))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func handlePostMessage(url: URL, bodyData: Data) {
        let pathComponents = url.path.split(separator: "/")

        guard pathComponents.count >= 3,
              let sessionId = Int(pathComponents[2]) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: bodyData) as? [String: String],
            let text = json["text"]
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotParseResponse))
            return
        }

        let userMessage = Message(
            id: UUID(),
            text: text,
            sender: .user,
            timestamp: Date()
        )

        if MockURLProtocol.messagesStorage[sessionId] == nil {
            MockURLProtocol.messagesStorage[sessionId] = []
        }
        MockURLProtocol.messagesStorage[sessionId]?.append(userMessage)

        let aiResponse = Message(
            id: UUID(),
            text: "Thank you for sharing that. Let me think about what you said: \"\(text)\". How does that make you feel?",
            sender: .ai,
            timestamp: Date().addingTimeInterval(1)
        )
        MockURLProtocol.messagesStorage[sessionId]?.append(aiResponse)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(userMessage),
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: 201,
                  httpVersion: nil,
                  headerFields: ["Content-Type": "application/json"]
              )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.cannotDecodeContentData))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

}

private extension Data {
    init(reading input: InputStream) {
        self.init()
        input.open()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
            input.close()
        }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read > 0 {
                append(buffer, count: read)
            } else {
                break
            }
        }
    }
}
