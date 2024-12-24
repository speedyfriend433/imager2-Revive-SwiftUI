//
//  DocumentAnalysisView.swift
//  imager2
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct DocumentAnalysisView: View {
    let metrics: DocumentAnalyzer.DocumentMetrics
    
    var body: some View {
        List {
            Section(header: Text("Basic Metrics")) {
                MetricRow(title: "Word Count", value: "\(metrics.wordCount)")
                MetricRow(title: "Character Count", value: "\(metrics.characterCount)")
                MetricRow(title: "Sentences", value: "\(metrics.sentenceCount)")
                MetricRow(title: "Paragraphs", value: "\(metrics.paragraphCount)")
            }
            
            Section(header: Text("Advanced Metrics")) {
                MetricRow(title: "Unique Words", value: "\(metrics.uniqueWords)")
                MetricRow(title: "Average Word Length",
                         value: String(format: "%.1f characters", metrics.avgWordLength))
                MetricRow(title: "Reading Time",
                         value: String(format: "%.1f minutes", metrics.readingTime))
            }
            
            Section(header: Text("Language Distribution")) {
                ForEach(Array(metrics.languageDistribution.keys.sorted()), id: \.self) { languageCode in
                    if let confidence = metrics.languageDistribution[languageCode] {
                        MetricRow(
                            title: getLanguageName(languageCode),
                            value: String(format: "%.1f%%", confidence * 100)
                        )
                    }
                }
            }
        }
        .navigationTitle("Document Analysis")
    }
    
    private func getLanguageName(_ code: String) -> String {
        let locale = Locale(identifier: "en")
        if let languageName = locale.localizedString(forLanguageCode: code) {
            return languageName.capitalized
        }
        return code
    }
}

struct MetricRow: View {
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
