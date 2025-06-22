import SwiftUI

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

//    private var sessionService = SessionService.shared
    private var sessionService = SessionServiceMock.shared

    func loadSessions() {
        isLoading = true
        sessionService.getSessions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let sessions):
                    self?.sessions = sessions.sorted { $0.date > $1.date }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}