//
//  CreateSessionViewModel.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import Foundation

class CreateSessionViewModel: ObservableObject {

    @Published var title = ""
    @Published var selectedCategory: Category = .career
    @Published var isCreatingSession = false
    @Published var error: Error? = nil
    @Published var createdSession: Session? = nil

    private var sessionService = SessionService.shared

    func createSession(completion: @escaping (Bool) -> Void) {
        isCreatingSession = true

        sessionService.createSession(title: title, category: selectedCategory) { [weak self] result in
            DispatchQueue.main.async {
                self?.isCreatingSession = false

                switch result {
                case let .success(session):
                    self?.createdSession = session
                    completion(true)
                case let .failure(error):
                    self?.error = error
                    completion(false)
                }
            }
        }
    }

}
