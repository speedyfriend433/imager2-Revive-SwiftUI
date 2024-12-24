//
//  SpellCheckView.swift
//  imager2
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct SpellCheckView: View {
    let text: String
    @ObservedObject var spellChecker: SpellCheckManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if spellChecker.misspelledWords.isEmpty {
                    Text("No spelling errors found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(spellChecker.misspelledWords, id: \.self) { word in
                        VStack(alignment: .leading) {
                            Text(word)
                                .foregroundColor(.red)
                            
                            if let suggestions = spellChecker.suggestions[word] {
                                Text("Suggestions:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(suggestions.prefix(3), id: \.self) { suggestion in
                                    Text(suggestion)
                                        .font(.subheadline)
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Spell Check")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .onAppear {
                spellChecker.checkSpelling(text: text, language: "en")
            }
        }
    }
}
