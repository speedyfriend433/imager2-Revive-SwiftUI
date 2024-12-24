//
//  DocumentListView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct DocumentListView: View {
    @StateObject private var storageManager = LocalStorageManager()
    @State private var showingNewDocument = false
    @State private var searchText = ""
    
    var filteredDocuments: [LocalDocument] {
        if searchText.isEmpty {
            return storageManager.documents
        }
        return storageManager.documents.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredDocuments) { document in
                    NavigationLink(destination: TextEditorView(
                        document: binding(for: document)
                    )) {
                        DocumentRow(document: document)
                    }
                }
                .onDelete(perform: deleteDocuments)
            }
            .searchable(text: $searchText)
            .navigationTitle("Documents")
            .toolbar {
                Button(action: { showingNewDocument = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewDocument) {
            NewDocumentView(storageManager: storageManager)
        }
    }
    
    private func binding(for document: LocalDocument) -> Binding<LocalDocument> {
        Binding(
            get: { document },
            set: { storageManager.saveDocument($0) }
        )
    }
    
    private func deleteDocuments(at offsets: IndexSet) {
        offsets.forEach { index in
            storageManager.deleteDocument(filteredDocuments[index])
        }
    }
}

struct DocumentRow: View {
    let document: LocalDocument
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.title)
                .font(.headline)
            Text(document.content.prefix(50) + "...")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(document.lastModified, style: .date)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
