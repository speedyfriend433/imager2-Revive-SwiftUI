//
//  DocumentAnalyzer.swift
//  imager2
//
//  Created by speedy on 2024/12/24.
//

import Foundation
import NaturalLanguage

class DocumentAnalyzer: ObservableObject {
    struct DocumentMetrics {
        let wordCount: Int
        let characterCount: Int
        let sentenceCount: Int
        let paragraphCount: Int
        let readingTime: TimeInterval
        let uniqueWords: Int
        let avgWordLength: Double
        let languageDistribution: [String: Double]
    }
    
    func analyzeDocument(_ text: String) -> DocumentMetrics {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let uniqueWords = Set(words.map { $0.lowercased() }).count
        let totalWordLength = words.reduce(0) { $0 + $1.count }
        let avgWordLength = words.isEmpty ? 0 : Double(totalWordLength) / Double(words.count)
        
        let languageDistribution = detectLanguageDistribution(text)
        
        return DocumentMetrics(
            wordCount: words.count,
            characterCount: text.count,
            sentenceCount: text.components(separatedBy: [".", "!", "?"]).filter { !$0.isEmpty }.count,
            paragraphCount: text.components(separatedBy: "\n\n").filter { !$0.isEmpty }.count,
            readingTime: Double(words.count) / 200.0,
            uniqueWords: uniqueWords,
            avgWordLength: avgWordLength,
            languageDistribution: languageDistribution
        )
    }
    
    private func detectLanguageDistribution(_ text: String) -> [String: Double] {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        let hypotheses = recognizer.languageHypotheses(withMaximum: 3)
        
        var distribution: [String: Double] = [:]
        for (language, confidence) in hypotheses {
            distribution[language.rawValue] = confidence
        }
        
        return distribution
    }
    
    private func getLanguageName(_ code: String) -> String {
        let locale = Locale(identifier: "en")
        if let languageName = locale.localizedString(forLanguageCode: code) {
            return languageName.capitalized
        }
        return code
    }
}
