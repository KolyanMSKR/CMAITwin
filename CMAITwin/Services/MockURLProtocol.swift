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

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return url.host == "mock.api" && url.path.starts(with: "/api/sessions")
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        if url.path.starts(with: "/api/sessions/"), url.path.hasSuffix("/messages") {
            handleMessages(url: url)
            return
        }

        switch (url.path, request.httpMethod) {
        case ("/api/sessions", "GET"):
            handleGET(url: url)

        case ("/api/sessions", "POST"):
            if let stream = request.httpBodyStream {
                let data = Data(reading: stream)
                handlePOST(url: url, bodyData: data)
            } else if let body = request.httpBody {
                handlePOST(url: url, bodyData: body)
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

    private func handleGET(url: URL) {
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

    private func handlePOST(url: URL, bodyData: Data) {
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

    private func handleMessages(url: URL) {
        let sampleMessages: [Message] = [
            Message(id: UUID(), text: "Hi! How are you today?", sender: .ai, timestamp: Date().addingTimeInterval(-300)),
            Message(id: UUID(), text: "Feeling a bit overwhelmed with work.", sender: .user, timestamp: Date().addingTimeInterval(-240)),
            Message(id: UUID(), text: "Let's break it down. What's causing the stress?", sender: .ai, timestamp: Date().addingTimeInterval(-180))
        ]

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard
            let data = try? encoder.encode(sampleMessages),
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
