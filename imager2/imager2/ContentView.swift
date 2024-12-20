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
                            
                            HStack {
                                Button(action: copyToClipboard) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                
                                Divider()
                                
                                Button(action: { showShareSheet = true }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }
                            .padding()
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
                ShareSheet(items: [recognizedText])
            }
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = recognizedText
        alertMessage = "Text copied to clipboard!"
        showAlert = true
    }
}

#Preview {
    ContentView()
}
