//
//  SpellCheckManager.swift
//  imager2
//
//  Created by speedy on 2024/12/24.
//

import Foundation
import UIKit
import NaturalLanguage

class SpellCheckManager: ObservableObject {
    private let checker = UITextChecker()
    @Published var misspelledWords: [String] = []
    @Published var suggestions: [String: [String]] = [:]
    
    func checkSpelling(text: String, language: String) {
        misspelledWords.removeAll()
        suggestions.removeAll()
        
        let range = NSRange(location: 0, length: text.utf16.count)
        var offset = 0
        
        while offset < text.utf16.count {
            let wordRange = checker.rangeOfMisspelledWord(
                in: text,
                range: NSRange(location: offset, length: text.utf16.count - offset),
                startingAt: offset,
                wrap: false,
                language: language
            )
            
            if wordRange.location == NSNotFound {
                break
            }
            
            if let range = Range(wordRange, in: text) {
                let word = String(text[range])
                misspelledWords.append(word)
                
                let guesses = checker.guesses(
                    forWordRange: wordRange,
                    in: text,
                    language: language
                ) ?? []
                
                suggestions[word] = guesses
            }
            
            offset = wordRange.location + wordRange.length
        }
    }
}
