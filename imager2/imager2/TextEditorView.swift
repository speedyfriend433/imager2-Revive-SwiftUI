//
//  TextEditorView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI
import PDFKit
import Speech

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
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                mainToolbar
                
                ScrollView {
                    VStack(spacing: 16) {

                        titleSection
                        
                        textEditorSection
                        
                        statisticsPreview
                    }
                    .padding()
                }
                
                if isEditingFormat {
                    FormatToolbar(options: $document.formattingOptions)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingStats) {
            TextStatsView(statistics: TextStatistics(text: document.content))
        }
        .sheet(isPresented: $showingVoiceInput) {
            SpeechRecognitionView(text: $document.content)
        }
        .sheet(isPresented: $showingVersionHistory) {
            VersionHistoryView(versions: versionManager.versions) { version in
                document.content = version.content
                showingVersionHistory = false
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = PDFExporter.exportToPDF(document: document) {
                ShareSheet(items: [pdfData])
            }
        }
        .alert("Message", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - View Components
    
    private var mainToolbar: some View {
        HStack {

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: { showingVoiceInput = true }) {
                    Image(systemName: "mic")
                }
                
                Button(action: { isEditingFormat.toggle() }) {
                    Image(systemName: "textformat")
                        .foregroundColor(isEditingFormat ? .blue : .primary)
                }
                
                Menu {
                    Button(action: { showingStats = true }) {
                        Label("Statistics", systemImage: "chart.bar")
                    }
                    
                    Button(action: { showingVersionHistory = true }) {
                        Label("Version History", systemImage: "clock")
                    }
                    
                    Button(action: exportPDF) {
                        Label("Export PDF", systemImage: "arrow.up.doc")
                    }
                    
                    Button(action: copyToClipboard) {
                        Label("Copy All", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("Share", systemImage: "square.and.arrow.up")
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
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var titleSection: some View {
        TextField("Title", text: $document.title)
            .font(.title2)
            .fontWeight(.bold)
            .textFieldStyle(PlainTextFieldStyle())
    }
    
    private var textEditorSection: some View {
        TextEditor(text: $document.content)
            .font(.custom(
                document.formattingOptions.fontFamily,
                size: document.formattingOptions.fontSize
            ))
            .lineSpacing(document.formattingOptions.lineSpacing)
            .frame(minHeight: 200)
            .onChange(of: document.content) { newValue in
                versionManager.addVersion(
                    content: newValue,
                    previousContent: document.content
                )
            }
    }
    
    private var statisticsPreview: some View {
        let stats = TextStatistics(text: document.content)
        return HStack {
            Label("\(stats.wordCount) words", systemImage: "text.word.spacing")
            Spacer()
            Label(String(format: "%.1f min read", stats.readingTime),
                  systemImage: "clock")
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
    
    // MARK: - Helper Functions
    
    private func exportPDF() {
        if let pdfData = PDFExporter.exportToPDF(document: document) {
            let av = UIActivityViewController(
                activityItems: [pdfData],
                applicationActivities: nil
            )
            UIApplication.shared.windows.first?.rootViewController?
                .present(av, animated: true)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = document.content
        alertMessage = "Content copied to clipboard"
        showingAlert = true
    }
}

// MARK: - Supporting Views

struct FormatToolbar: View {
    @Binding var options: TextFormattingOptions
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Font Size: \(Int(options.fontSize))")
                    .font(.caption)
                Slider(value: $options.fontSize, in: 8...32)
            }
            
            HStack {
                Text("Line Spacing: \(options.lineSpacing, specifier: "%.1f")")
                    .font(.caption)
                Slider(value: $options.lineSpacing, in: 1...2)
            }
            
            Picker("Font", selection: $options.fontFamily) {
                Text("Helvetica").tag("Helvetica")
                Text("Arial").tag("Arial")
                Text("Times New Roman").tag("Times New Roman")
                Text("Courier").tag("Courier")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                ForEach(TextFormattingOptions.TextAlignment.allCases, id: \.self) { alignment in
                    Button(action: { options.alignment = alignment }) {
                        Image(systemName: alignment.iconName)
                            .foregroundColor(options.alignment == alignment ? .blue : .primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct VersionHistoryView: View {
    let versions: [DocumentVersion]
    let onSelect: (DocumentVersion) -> Void
    
    var body: some View {
        NavigationView {
            List(versions) { version in
                VStack(alignment: .leading) {
                    Text(version.timestamp, style: .date)
                        .font(.headline)
                    Text(version.changes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(version)
                }
            }
            .navigationTitle("Version History")
        }
    }
}

// MARK: - Helper Extensions

// extension TextAlignment {
//     static var allCases: [TextAlignment] = [.left, .center, .right]
//
//     var iconName: String {
//         switch self {
//         case .left: return "text.align.left"
//         case .center: return "text.align.center"
//         case .right: return "text.align.right"
//         }
//     }
// }

// Preview
struct TextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorView(document: .constant(LocalDocument(
            title: "Sample Document",
            content: "Sample content",
            language: "en-US"
        )))
    }
}
