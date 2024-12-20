//
//  PDFExporter.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import PDFKit
import SwiftUI

struct PDFExporter {
    static func exportToPDF(document: LocalDocument) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "TextExtractor App",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: document.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw title
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let titleString = document.title
            titleString.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // Draw content
            let textAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            let textRect = CGRect(x: 50, y: 100, width: pageRect.width - 100, height: pageRect.height - 150)
            document.content.draw(in: textRect, withAttributes: textAttributes)
        }
        
        return data
    }
}
