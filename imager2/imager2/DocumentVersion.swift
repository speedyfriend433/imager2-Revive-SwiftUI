//
//  DocumentVersion.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import Foundation

struct DocumentVersion: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let changes: String
}

class VersionManager: ObservableObject {
    @Published var versions: [DocumentVersion] = []
    private let maxVersions = 10
    
    func addVersion(content: String, previousContent: String?) {
        let changes = calculateChanges(from: previousContent ?? "", to: content)
        let version = DocumentVersion(
            id: UUID(),
            content: content,
            timestamp: Date(),
            changes: changes
        )
        
        versions.insert(version, at: 0)
        if versions.count > maxVersions {
            versions.removeLast()
        }
    }
    
    private func calculateChanges(from old: String, to new: String) -> String {

        if old == new { return "No changes" }
        let addedCount = new.count - old.count
        return addedCount >= 0 ? "Added \(addedCount) characters" : "Removed \(-addedCount) characters"
    }
}
