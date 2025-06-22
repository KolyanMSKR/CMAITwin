//
//  MockURLProtocol.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

class MockURLProtocol: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.path == "/api/sessions"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            return
        }

        if url.path == "/api/sessions" {
            let sessions: [Session] = [
                Session(id: 1, date: Date().addingTimeInterval(-3600), title: "Career Chat", category: .career, summary: "Talked about job goals."),
                Session(id: 2, date: Date().addingTimeInterval(-86400), title: "Feeling Stressed", category: .emotions, summary: "Discussed coping strategies."),
                Session(id: 3, date: Date().addingTimeInterval(-172800), title: "Relationship talk", category: .productivity, summary: "Discussed communication.")
            ]

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            guard let data = try? encoder.encode(sessions) else {
                return
            }

            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ) else {
                return
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }

}
