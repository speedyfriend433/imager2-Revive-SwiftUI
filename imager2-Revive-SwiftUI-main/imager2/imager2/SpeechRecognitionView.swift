//
//  SpeechRecognitionView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI
import Speech

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

struct SpeechRecognitionView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Binding var text: String
    
    var body: some View {
        VStack {
            Text(speechRecognizer.transcribedText)
                .padding()
                .frame(height: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording()
                    text = speechRecognizer.transcribedText
                } else {
                    try? speechRecognizer.startRecording()
                }
            }) {
                Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
            }
        }
    }
}
