//
//  AIChatViewModel.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

class AIChatViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let sessionService: SessionService
    private let sessionId: Int

    // MARK: - Inits

    init(sessionService: SessionService, sessionId: Int) {
        self.sessionService = sessionService
        self.sessionId = sessionId
    }

    // MARK: - Public methods

    func loadMessages() {
        isLoading = true
        error = nil

        sessionService.fetchMessages(for: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case let .success(messages):
                    self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
                case let .failure(error):
                    self?.error = error
                }
            }
        }
    }

    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        sessionService.sendMessage(sessionId: sessionId, text: trimmedText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadMessages()
                case let .failure(error):
                    self?.error = error
                }
            }
        }
    }

}
