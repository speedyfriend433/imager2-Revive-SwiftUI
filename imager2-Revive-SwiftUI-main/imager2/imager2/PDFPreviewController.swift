//
//  PDFPreviewController.swift
//  imager2
//
//  Created by speedy on 2024/12/24.
//

import PDFKit
import SwiftUI

struct PDFPreviewController: UIViewControllerRepresentable {
    let pdfData: Data
    
    func makeUIViewController(context: Context) -> PDFViewController {
        let controller = PDFViewController(pdfData: pdfData)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PDFViewController,
                              context: Context) {}
}

class PDFViewController: UIViewController {
    private let pdfData: Data
    private var pdfView: PDFView!
    
    init(pdfData: Data) {
        self.pdfData = pdfData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPDFView()
    }
    
    private func setupPDFView() {
        pdfView = PDFView(frame: view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pdfView)
        
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.displayMode = .singlePage
            pdfView.displayDirection = .vertical
        }
    }
}
