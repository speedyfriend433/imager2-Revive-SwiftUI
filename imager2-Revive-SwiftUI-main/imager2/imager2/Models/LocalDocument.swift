//
//  LocalDocument.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct LocalDocument: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var language: String
    var timestamp: Date
    var lastModified: Date
    var formattingOptions: TextFormattingOptions
    
    init(id: UUID = UUID(), title: String, content: String, language: String) {
        self.id = id
        self.title = title
        self.content = content
        self.language = language
        self.timestamp = Date()
        self.lastModified = Date()
        self.formattingOptions = TextFormattingOptions()
    }
}

struct TextFormattingOptions: Codable {
    var fontSize: CGFloat = 16
    var fontFamily: String = "Helvetica"
    var alignment: TextAlignment = .left
    var lineSpacing: CGFloat = 1.2
    var textColor: String = "#000000"
    var isSpellCheckEnabled: Bool = true
    
    enum TextAlignment: String, Codable, CaseIterable {
        case left
        case center
        case right
        
        var iconName: String {
            switch self {
            case .left: return "text.align.left"
            case .center: return "text.align.center"
            case .right: return "text.align.right"
            }
        }
    }
}
