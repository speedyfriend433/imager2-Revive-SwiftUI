//
//  TextStatistics.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct TextStatistics {
    let wordCount: Int
    let characterCount: Int
    let sentenceCount: Int
    let paragraphCount: Int
    let readingTime: TimeInterval
    
    init(text: String) {
        self.wordCount = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
        self.characterCount = text.count
        self.sentenceCount = text.components(separatedBy: [".", "!", "?"])
            .filter { !$0.isEmpty }.count
        self.paragraphCount = text.components(separatedBy: "\n\n").count
        self.readingTime = Double(wordCount) / 200.0 // Average reading speed
    }
}

struct TextStatsView: View {
    let statistics: TextStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Text Statistics")
                .font(.headline)
            
            Group {
                StatRow(title: "Words", value: "\(statistics.wordCount)")
                StatRow(title: "Characters", value: "\(statistics.characterCount)")
                StatRow(title: "Sentences", value: "\(statistics.sentenceCount)")
                StatRow(title: "Paragraphs", value: "\(statistics.paragraphCount)")
                StatRow(title: "Reading Time",
                       value: String(format: "%.1f min", statistics.readingTime))
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
