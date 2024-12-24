//
//  ContentView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI
import Vision
import VisionKit

struct ContentView: View {
    @State private var recognizedText = ""
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var selectedLanguage: RecognitionLanguage = .english
    @State private var isProcessing = false
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingExportOptions = false
    @State private var showingDetailedStats = false
    @State private var pdfData: Data?
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(RecognitionLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    
                    HStack(spacing: 20) {
                        Button(action: { showImagePicker = true }) {
                            ImageButtonView(systemName: "photo.on.rectangle", text: "Gallery")
                        }
                        
                        Button(action: { showCamera = true }) {
                            ImageButtonView(systemName: "camera", text: "Camera")
                        }
                    }
                    
                    if !recognizedText.isEmpty {
                        VStack {
                            Text("Extracted Text")
                                .font(.headline)
                            
                            TextEditor(text: .constant(recognizedText))
                                .frame(height: 200)
                                .padding(5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .focused($isEditorFocused)
                            
                            QuickStatsView(statistics: TextStatistics(text: recognizedText))
                                .padding(.vertical, 8)
                            
                            HStack(spacing: 20) {
                                Button(action: copyToClipboard) {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy")
                                    }
                                    .foregroundColor(.blue)
                                }
                                
                                Button(action: { showingExportOptions = true }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Export")
                                    }
                                    .foregroundColor(.blue)
                                }
                                
                                Button(action: { showingDetailedStats = true }) {
                                    HStack {
                                        Image(systemName: "chart.bar")
                                        Text("Stats")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .padding()
                    }
                }
                .overlay(
                    Group {
                        if isProcessing {
                            ProgressView("Processing...")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                )
            }
            .navigationTitle("Text Extractor")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            showingExportOptions = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            isEditorFocused = false
                        }
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage,
                           recognizedText: $recognizedText,
                           isProcessing: $isProcessing,
                           selectedLanguage: selectedLanguage)
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $selectedImage,
                          recognizedText: $recognizedText,
                          isProcessing: $isProcessing,
                          selectedLanguage: selectedLanguage)
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfData = self.pdfData {
                    ShareSheet(items: [pdfData])
                } else {
                    ShareSheet(items: [recognizedText])
                }
            }
            .sheet(isPresented: $showingDetailedStats) {
                NavigationView {
                    DetailedStatsView(statistics: TextStatistics(text: recognizedText))
                }
            }
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog(
                "Export Options",
                isPresented: $showingExportOptions,
                titleVisibility: .visible
            ) {
                Button("Export as PDF") {
                    exportPDF()
                }
                
                Button("Share as Text") {
                    showShareSheet = true
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose export format")
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = recognizedText
        alertMessage = "Text copied to clipboard!"
        showAlert = true
    }
    
    private func exportPDF() {
        let document = LocalDocument(
            title: "Extracted Text",
            content: recognizedText,
            language: selectedLanguage.rawValue
        )
        
        if let data = PDFExporter.exportToPDF(document: document) {
            pdfData = data
            showShareSheet = true
        } else {
            alertMessage = "Failed to generate PDF"
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
