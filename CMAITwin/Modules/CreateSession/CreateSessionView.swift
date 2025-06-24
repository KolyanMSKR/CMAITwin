//
//  CreateSessionView.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

struct CreateSessionView: View {

    @Environment(\.sessionService) private var sessionService
    @StateObject private var viewModel: CreateSessionViewModel
    @State private var isSessionCreated = false

    // MARK: - Inits

    init() {
        _viewModel = StateObject(wrappedValue: CreateSessionViewModel(sessionService: SessionService(client: APIClient.shared)))
    }

    // MARK: - Body Property

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter session title", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                VStack(alignment: .leading) {
                    Text("Pick a category:")
                        .padding(.horizontal, 20)
                        .padding(.bottom, -12)

                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.emoji + " " + category.rawValue.capitalized)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                Spacer()

                Button {
                    viewModel.createSession { success in
                        if success {
                            isSessionCreated = true
                        }
                    }
                } label: {
                    HStack {
                        Text("Start Session")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .background(viewModel.title.isEmpty ? .gray.opacity(0.2) : .blue)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .disabled(viewModel.title.isEmpty)
            }
            .navigationTitle("Create New Session")
            .navigationDestination(isPresented: $isSessionCreated) {
                AIChatView(sessionId: viewModel.createdSession?.id ?? -1)
            }
        }
    }

}

#Preview {
    CreateSessionView()
}
