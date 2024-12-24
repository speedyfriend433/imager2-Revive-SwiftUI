//
//  DocumentVersion.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import Foundation
import SwiftUI

struct DocumentVersion: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let changes: String
    
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), changes: String) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.changes = changes
    }
}

class VersionManager: ObservableObject {
    @Published var versions: [DocumentVersion] = []
    private let maxVersions = 10
    
    func addVersion(content: String, previousContent: String?) {
        let changes = calculateChanges(from: previousContent ?? "", to: content)
        let version = DocumentVersion(
            content: content,
            changes: changes
        )
        
        versions.insert(version, at: 0)
        if versions.count > maxVersions {
            versions.removeLast()
        }
    }
    
    private func calculateChanges(from old: String, to new: String) -> String {
        if old == new { return "No changes" }
        
        let oldWords = old.split(separator: " ").count
        let newWords = new.split(separator: " ").count
        let wordDiff = newWords - oldWords
        
        let oldChars = old.count
        let newChars = new.count
        let charDiff = newChars - oldChars
        
        var changes = ""
        
        if wordDiff != 0 {
            changes += wordDiff > 0 ? "Added \(wordDiff) words" : "Removed \(-wordDiff) words"
        }
        
        if charDiff != 0 {
            if !changes.isEmpty {
                changes += ", "
            }
            changes += charDiff > 0 ? "Added \(charDiff) characters" : "Removed \(-charDiff) characters"
        }
        
        return changes.isEmpty ? "Modified content" : changes
    }
    
    func restoreVersion(_ version: DocumentVersion) -> String {
        return version.content
    }
}

