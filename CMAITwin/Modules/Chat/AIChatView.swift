//
//  AIChatView.swift
//  CMAITwin
//
//  Created by Anderen on 22.06.2025.
//

import SwiftUI

struct AIChatView: View {

    let sessionId: Int

    @StateObject private var viewModel = AIChatViewModel()
    @State private var inputText: String = ""

    // MARK: - Body property

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
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
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .navigationTitle("AI Chat")
        .onAppear {
            viewModel.loadMessages(for: sessionId)
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
