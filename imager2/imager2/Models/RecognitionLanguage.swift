//
//  RecognitionLanguage.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import Foundation

enum RecognitionLanguage: String, CaseIterable {
    case english = "en-US"
    case spanish = "es"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case chinese = "zh-Hans"
    
    var displayName: String {
        switch self {
            case .english: return "English"
            case .spanish: return "Spanish"
            case .korean: return "Korean"
            case .french: return "French"
            case .german: return "German"
            case .chinese: return "Chinese"
        }
    }
}
