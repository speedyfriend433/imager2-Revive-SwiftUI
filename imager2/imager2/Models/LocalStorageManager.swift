//
//  LocalStorageManager.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import Foundation

class LocalStorageManager: ObservableObject {
    @Published var documents: [LocalDocument] = []
    private let documentsKey = "saved_documents"
    
    init() {
        loadDocuments()
    }
    
    func saveDocument(_ document: LocalDocument) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index] = document
        } else {
            documents.append(document)
        }
        saveToUserDefaults()
    }
    
    func deleteDocument(_ document: LocalDocument) {
        documents.removeAll { $0.id == document.id }
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(documents) {
            UserDefaults.standard.set(encoded, forKey: documentsKey)
        }
    }
    
    private func loadDocuments() {
        if let data = UserDefaults.standard.data(forKey: documentsKey),
           let decoded = try? JSONDecoder().decode([LocalDocument].self, from: data) {
            documents = decoded
        }
    }
}
