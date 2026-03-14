// SearchBar.swift
// A reusable, debounced search bar component.
//
// Debouncing prevents the filter from re-running on every keystroke,
// which is important for large datasets. The default debounce delay
// is 0.25 seconds — fast enough to feel responsive, slow enough to
// avoid unnecessary work.

import SwiftUI
import Combine

struct SearchBar: View {

    @Binding var text: String
    var placeholder: String = "Search…"
    var debounceDelay: Double = 0.25

    @State private var inputText: String = ""
    @State private var debounceTask: Task<Void, Never>? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.body)

            TextField(placeholder, text: $inputText)
                .textFieldStyle(.plain)
                .onChange(of: inputText) { _, newValue in
                    debounceTask?.cancel()
                    debounceTask = Task {
                        try? await Task.sleep(for: .seconds(debounceDelay))
                        if !Task.isCancelled {
                            await MainActor.run { text = newValue }
                        }
                    }
                }

            if !inputText.isEmpty {
                Button {
                    inputText = ""
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .onAppear { inputText = text }
    }
}
