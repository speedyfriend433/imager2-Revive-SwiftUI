//
//  TextEditorView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI
import PDFKit
import Speech
import UIKit

struct TextEditorView: View {
    @Binding var document: LocalDocument
    @StateObject private var versionManager = VersionManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditingFormat: Bool = false
    @State private var selectedText: String = ""
    @State private var showingStats = false
    @State private var showingVoiceInput = false
    @State private var showingVersionHistory = false
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var showingAlert = false
    @State private var showingPDFPreview = false // Added
    @State private var pdfData: Data? // Added
    @State private var alertMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var content: String
    @State private var title: String
    @FocusState private var isEditorFocused: Bool // Added
    @StateObject private var spellChecker = SpellCheckManager()
    @StateObject private var documentAnalyzer = DocumentAnalyzer()
    @State private var showingAnalysis = false
    @State private var showingSpellCheck = false
    
    
    init(document: Binding<LocalDocument>) {
        self._document = document
        self._content = State(initialValue: document.wrappedValue.content)
        self._title = State(initialValue: document.wrappedValue.title)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                customNavigationBar
                
                ScrollView {
                    VStack(spacing: 16) {
                        TextField("Title", text: $title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .onChange(of: title) { newValue in
                                document.title = newValue
                            }
                        
                        TextEditor(text: $content)
                            .font(.system(size: document.formattingOptions.fontSize))
                            .lineSpacing(document.formattingOptions.lineSpacing)
                            .frame(minHeight: 300)
                            .padding(.horizontal)
                            .focused($isEditorFocused)
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
                            .onChange(of: content) { newValue in
                                document.content = newValue
                                versionManager.addVersion(
                                    content: newValue,
                                    previousContent: document.content
                                )
                            }
                        
                        statisticsPreview
                    }
                    .padding(.vertical)
                }
                
                if isEditingFormat {
                    formattingBar
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
            .confirmationDialog(
                "Export Options",
                isPresented: $showingExportOptions,
                titleVisibility: .visible
            ) {
                Button("Export as PDF") {
                    exportPDF()
                }
                
                Button("Copy to Clipboard") {
                    copyToClipboard()
                }
                
                Button("Share as Text") {
                    showingShareSheet = true
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose export format")
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let data = pdfData {
                    NavigationView {
                        PDFPreviewController(pdfData: data)
                            .navigationTitle("PDF Preview")
                            .navigationBarItems(
                                leading: Button("Cancel") {
                                    showingPDFPreview = false
                                },
                                trailing: Button("Share") {
                                    showingPDFPreview = false
                                    showingShareSheet = true
                                }
                            )
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = self.pdfData {
                    ShareSheet(items: [pdfData])
                } else {
                    ShareSheet(items: [content])
                }
            }
            .sheet(isPresented: $showingAnalysis) {
                NavigationView {
                    DocumentAnalysisView(metrics: documentAnalyzer.analyzeDocument(content))
                }
            }
            .sheet(isPresented: $showingSpellCheck) {
                SpellCheckView(text: content, spellChecker: spellChecker)
            }
            .sheet(isPresented: $showingVersionHistory) {
                NavigationView {
                    VersionHistoryView(versions: versionManager.versions) { version in
                        content = versionManager.restoreVersion(version)
                    }
                }
            }
            .alert("Message", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Components
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: { showingVoiceInput = true }) {
                    Image(systemName: "mic")
                }
                
                Button(action: { isEditorFocused = false }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                
                Button(action: {
                    withAnimation {
                        isEditingFormat.toggle()
                    }
                }) {
                    Image(systemName: "textformat")
                        .foregroundColor(isEditingFormat ? .blue : .primary)
                }
                
                Menu {
                    Button(action: { showingAnalysis = true }) {
                        Label("Document Analysis", systemImage: "chart.bar.doc.horizontal")
                    }
                    
                    Button(action: { showingSpellCheck = true }) {
                        Label("Spell Check", systemImage: "textformat.abc")
                    }
    
                    Button(action: { showingStats = true }) {
                        Label("Statistics", systemImage: "chart.bar")
                    }
                    
                    Button(action: { showingVersionHistory = true }) {
                        Label("Version History", systemImage: "clock")
                    }
                    
                    Button(action: { showingExportOptions = true }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
                .opacity(0.5),
            alignment: .bottom
        )
    }
    
    private var formattingBar: some View {
        VStack(spacing: 12) {
            
            HStack {
                Text("Font Size")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { document.formattingOptions.fontSize },
                        set: { document.formattingOptions.fontSize = $0 }
                    ),
                    in: 12...24,
                    step: 1
                )
                
                Text("\(Int(document.formattingOptions.fontSize))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 30)
            }
            
            HStack {
                Text("Line Spacing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { document.formattingOptions.lineSpacing },
                        set: { document.formattingOptions.lineSpacing = $0 }
                    ),
                    in: 1...2,
                    step: 0.1
                )
                
                Text(String(format: "%.1f", document.formattingOptions.lineSpacing))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 30)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var statisticsPreview: some View {
        let stats = TextStatistics(text: content)
        return HStack {
            Label("\(stats.wordCount) words", systemImage: "text.word.spacing")
            Spacer()
            Label(String(format: "%.1f min read", stats.readingTime),
                  systemImage: "clock")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
        
        private func exportPDF() {
            if let data = PDFExporter.exportToPDF(document: document) {
                pdfData = data
                showingPDFPreview = true
            } else {
                alertMessage = "Failed to generate PDF"
                showingAlert = true
            }
        }
        
        private func copyToClipboard() {
            UIPasteboard.general.string = content
            alertMessage = "Content copied to clipboard"
            showingAlert = true
        }
    }
    
    // MARK: - Supporting Views and Models
    
    /*struct ShareSheet: UIViewControllerRepresentable {
     let items: [Any]
     
     func makeUIViewController(context: Context) -> UIActivityViewController {
     UIActivityViewController(activityItems: items, applicationActivities: nil)
     }
     
     func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
     }
     
     struct TextStatistics {
     let wordCount: Int
     let characterCount: Int
     let readingTime: TimeInterval
     
     init(text: String) {
     self.wordCount = text.components(separatedBy: .whitespacesAndNewlines)
     .filter { !$0.isEmpty }.count
     self.characterCount = text.count
     self.readingTime = Double(wordCount) / 200.0
     }
     }
     
     struct SpeechRecognitionView: View {
     @Binding var text: String
     @Environment(\.presentationMode) var presentationMode
     @StateObject private var speechRecognizer = SpeechRecognizer()
     
     var body: some View {
     NavigationView {
     VStack {
     Text(speechRecognizer.transcribedText)
     .padding()
     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
     .background(Color(.systemGray6))
     
     Button(action: {
     if speechRecognizer.isRecording {
     speechRecognizer.stopRecording()
     text = speechRecognizer.transcribedText
     presentationMode.wrappedValue.dismiss()
     } else {
     try? speechRecognizer.startRecording()
     }
     }) {
     Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
     .font(.system(size: 44))
     .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
     }
     .padding()
     }
     .navigationTitle("Voice Input")
     .navigationBarTitleDisplayMode(.inline)
     .navigationBarItems(
     trailing: Button("Done") {
     presentationMode.wrappedValue.dismiss()
     }
     )
     }
     }
     }
     
     class SpeechRecognizer: ObservableObject {
     @Published var isRecording = false
     @Published var transcribedText = ""
     private var audioEngine = AVAudioEngine()
     private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
     private var recognitionTask: SFSpeechRecognitionTask?
     private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
     
     func startRecording() throws {
     transcribedText = ""
     
     let audioSession = AVAudioSession.sharedInstance()
     try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
     try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
     
     recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
     
     let inputNode = audioEngine.inputNode
     recognitionRequest?.shouldReportPartialResults = true
     
     recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, error in
     if let result = result {
     self.transcribedText = result.bestTranscription.formattedString
     }
     }
     
     let recordingFormat = inputNode.outputFormat(forBus: 0)
     inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
     self.recognitionRequest?.append(buffer)
     }
     
     audioEngine.prepare()
     try audioEngine.start()
     isRecording = true
     }
     
     func stopRecording() {
     audioEngine.stop()
     recognitionRequest?.endAudio()
     isRecording = false
     }
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
     }*/
    
    private func calculateChanges(from old: String, to new: String) -> String {
        if old == new { return "No changes" }
        let addedCount = new.count - old.count
        return addedCount >= 0 ? "Added \(addedCount) characters" : "Removed \(-addedCount) characters"
    }
    
struct VersionHistoryView: View {
    let versions: [DocumentVersion]
    let onSelect: (DocumentVersion) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List(versions) { version in
            VStack(alignment: .leading, spacing: 4) {
                Text(version.timestamp, style: .date)
                    .font(.headline)
                Text(version.changes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(version)
                dismiss()
            }
        }
        .navigationTitle("Version History")
    }
}
    
    // MARK: - Helper Extensions
    
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
    }
    
    // MARK: - Preview Provider
    struct TextEditorView_Previews: PreviewProvider {
        static var previews: some View {
            TextEditorView(document: .constant(LocalDocument(
                title: "Sample Document",
                content: "Sample content goes here...",
                language: "en-US"
            )))
        }
    }
