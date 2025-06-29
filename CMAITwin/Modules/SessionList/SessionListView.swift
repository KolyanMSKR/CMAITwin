//
//  SessionListView.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

struct SessionListView: View {

    @StateObject private var viewModel: SessionViewModel
    @Environment(\.sessionService) private var sessionService

    // MARK: - Inits

    init() {
        _viewModel = StateObject(wrappedValue: SessionViewModel(sessionService: SessionService(client: APIClient.shared)))
    }

    // MARK: - Body Property

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let error = viewModel.error {
                    Text("Failed to load sessions: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.sessions) { session in
                        NavigationLink {
                            AIChatView(sessionId: session.id)
                        } label: {
                            HStack {
                                Text(session.category.emoji)
                                    .font(.title)
                                    .padding(.trailing, 8)

                                VStack(alignment: .leading) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text(session.summary)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text(session.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationBarTitle("AI Sessions")
            .navigationBarItems(
                leading: NavigationLink(destination: CreateSessionView()) {
                    Text("Start new session")
                        .fontWeight(.bold)
                },
                trailing: Button {
                    viewModel.loadSessions()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                viewModel.loadSessions()
            }
        }
    }

}

#Preview {
    SessionListView()
}
