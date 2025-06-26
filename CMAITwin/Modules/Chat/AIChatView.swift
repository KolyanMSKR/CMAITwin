//
//  AIChatView.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

struct AIChatView: View {

    private let sessionId: Int

    @Environment(\.sessionService) private var sessionService
    @StateObject private var viewModel: AIChatViewModel
    @State private var inputText: String = ""

    // MARK: - Inits

    init(sessionId: Int) {
        self.sessionId = sessionId
        _viewModel = StateObject(wrappedValue: AIChatViewModel(
            sessionService: SessionService(client: APIClient.shared),
            sessionId: sessionId
        ))
    }

    // MARK: - Body Property

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        if viewModel.isLoading && viewModel.messages.isEmpty {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding()
                        } else {
                            ForEach(viewModel.messages) { message in
                                HStack {
                                    if message.sender == .ai {
                                        bubble(text: message.text, color: .gray.opacity(0.2), alignment: .leading)
                                        Spacer()
                                    } else {
                                        Spacer()
                                        bubble(text: message.text, color: .blue.opacity(0.8), alignment: .trailing)
                                    }
                                }
                                .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Divider()

            HStack {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .frame(minHeight: 36)

                Button {
                    let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        return
                    }
                    viewModel.sendMessage(trimmed)
                    inputText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .navigationTitle("AI Chat")
        .onAppear {
            viewModel.loadMessages()
        }
    }

    // MARK: - Private methods

    private func bubble(text: String, color: Color, alignment: HorizontalAlignment) -> some View {
        Text(text)
            .padding(12)
            .background(color)
            .cornerRadius(16)
            .frame(maxWidth: 250, alignment: alignment == .leading ? .leading : .trailing)
    }

}

#Preview {
    AIChatView(sessionId: 1)
}
