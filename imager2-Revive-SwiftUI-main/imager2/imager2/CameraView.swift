//
//  CameraView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI
import Vision
import VisionKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var recognizedText: String
    @Binding var isProcessing: Bool
    let selectedLanguage: RecognitionLanguage
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.isProcessing = true
                recognizeText(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func recognizeText(_ image: UIImage) {
            guard let cgImage = image.cgImage else { return }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      error == nil else {
                    return
                }
                
                let text = observations.compactMap({
                    $0.topCandidates(1).first?.string
                }).joined(separator: "\n")
                
                DispatchQueue.main.async {
                    self.parent.recognizedText = text
                    self.parent.isProcessing = false
                }
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = [parent.selectedLanguage.rawValue]
            
            do {
                try handler.perform([request])
            } catch {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.parent.isProcessing = false
                }
            }
        }
    }
}
