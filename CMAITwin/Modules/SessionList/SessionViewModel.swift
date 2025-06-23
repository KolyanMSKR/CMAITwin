//
//  SessionViewModel.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

class SessionViewModel: ObservableObject {

    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

    private let sessionService: SessionService

    // MARK: - Inits

    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }

    // MARK: - Public methods

    func loadSessions() {
        isLoading = true

        sessionService.fetchSessions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case let .success(sessions):
                    self?.sessions = sessions.sorted { $0.date > $1.date }
                case let .failure(error):
                    self?.error = error
                }
            }
        }
    }

}
