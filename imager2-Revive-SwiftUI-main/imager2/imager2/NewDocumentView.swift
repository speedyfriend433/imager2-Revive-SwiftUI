//
//  NewDocumentView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct NewDocumentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var storageManager: LocalStorageManager
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var isProcessing = false
    @State private var selectedLanguage: RecognitionLanguage = .english
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Document Details")) {
                    TextField("Title", text: $title)
                    
                    TextEditor(text: $content)
                        .frame(height: 150)
                }
                
                Section(header: Text("Import Text from Image")) {
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(RecognitionLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    
                    HStack {
                        Button(action: { showImagePicker = true }) {
                            Label("Photo Library", systemImage: "photo")
                        }
                        
                        Divider()
                        
                        Button(action: { showCamera = true }) {
                            Label("Camera", systemImage: "camera")
                        }
                    }
                    
                    if isProcessing {
                        ProgressView("Processing image...")
                    }
                    
                    if !recognizedText.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recognized Text:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(recognizedText)
                                .font(.body)
                            
                            Button("Use This Text") {
                                content = recognizedText
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Document")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveDocument()
                }
                .disabled(title.isEmpty)
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(
                    image: $selectedImage,
                    recognizedText: $recognizedText,
                    isProcessing: $isProcessing,
                    selectedLanguage: selectedLanguage
                )
            }
            .sheet(isPresented: $showCamera) {
                CameraView(
                    image: $selectedImage,
                    recognizedText: $recognizedText,
                    isProcessing: $isProcessing,
                    selectedLanguage: selectedLanguage
                )
            }
        }
    }
    
    private func saveDocument() {
        let newDocument = LocalDocument(
            title: title,
            content: content.isEmpty ? recognizedText : content,
            language: selectedLanguage.rawValue
        )
        storageManager.saveDocument(newDocument)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        NewDocumentView(storageManager: LocalStorageManager())
    }
}
