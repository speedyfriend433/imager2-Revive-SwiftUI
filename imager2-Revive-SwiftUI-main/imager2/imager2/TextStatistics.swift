//
//  TextStatistics.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct TextStatistics {
    let text: String
    
    var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }.count
    }
    
    var characterCount: Int {
        text.count
    }
    
    var characterNoSpaces: Int {
        text.replacingOccurrences(of: " ", with: "").count
    }
    
    var lineCount: Int {
        text.components(separatedBy: .newlines).count
    }
    
    var sentenceCount: Int {
        text.components(separatedBy: [".", "!", "?"])
            .filter { !$0.isEmpty }.count
    }
    
    var readingTime: Double {

        Double(wordCount) / 200.0
    }
}

struct QuickStatsView: View {
    let statistics: TextStatistics
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatisticItemView(
                    title: "Words",
                    value: "\(statistics.wordCount)",
                    systemImage: "text.word.spacing"
                )
                
                Divider()
                
                StatisticItemView(
                    title: "Characters",
                    value: "\(statistics.characterCount)",
                    systemImage: "character.cursor.ibeam"
                )
            }
            
            Divider()
            
            HStack {
                StatisticItemView(
                    title: "Lines",
                    value: "\(statistics.lineCount)",
                    systemImage: "text.alignleft"
                )
                
                Divider()
                
                StatisticItemView(
                    title: "Reading Time",
                    value: String(format: "%.1f min", statistics.readingTime),
                    systemImage: "clock"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatisticItemView: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailedStatsView: View {
    let statistics: TextStatistics
    
    var body: some View {
        List {
            StatRow(title: "Words", value: "\(statistics.wordCount)")
            StatRow(title: "Characters (with spaces)", value: "\(statistics.characterCount)")
            StatRow(title: "Characters (no spaces)", value: "\(statistics.characterNoSpaces)")
            StatRow(title: "Lines", value: "\(statistics.lineCount)")
            StatRow(title: "Sentences", value: "\(statistics.sentenceCount)")
            StatRow(title: "Reading Time", value: String(format: "%.1f minutes", statistics.readingTime))
        }
        .navigationTitle("Text Statistics")
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
                .fontWeight(.medium)
        }
    }
}
