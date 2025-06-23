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

    private let sessionService = SessionService.shared

    func loadMessages(for sessionId: Int) {
        isLoading = true

        sessionService.fetchMessages(for: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let messages):
                    self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }

    func sendMessage(_ text: String) {
        let userMessage = Message(
            id: UUID(),
            text: text,
            sender: .user,
            timestamp: Date()
        )

        messages.append(userMessage)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let aiReply = Message(
                id: UUID(),
                text: "Let's talk more about \"\(text)\".",
                sender: .ai,
                timestamp: Date()
            )
            self.messages.append(aiReply)
        }
    }

}
