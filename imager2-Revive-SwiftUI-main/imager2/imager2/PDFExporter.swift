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

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        

        let pdfMetaData = [
            kCGPDFContextCreator: "TextExtractor App",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: document.title,
            kCGPDFContextSubject: "Document Export",
            kCGPDFContextKeywords: "text, document, export"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            let textRect = CGRect(x: margin, y: margin,
                                width: pageWidth - (2 * margin),
                                height: pageHeight - (2 * margin))
            
            context.beginPage()
            drawHeader(in: context, title: document.title, rect: pageRect)
            drawMetadata(document: document, in: textRect)
            

            let contentAttributes = getContentAttributes()
            let contentString = document.content as NSString
            let framesetter = CTFramesetterCreateWithAttributedString(
                NSAttributedString(
                    string: document.content,
                    attributes: contentAttributes
                )
            )
            
            var currentRange = CFRangeMake(0, 0)
            var currentPage: Int = 1
            
            while currentRange.location < contentString.length {
                context.beginPage()
                
                let contentRect = CGRect(x: margin, y: margin,
                                       width: pageWidth - (2 * margin),
                                       height: pageHeight - (2 * margin))
                
                let path = CGPath(rect: contentRect, transform: nil)
                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    currentRange,
                    path,
                    nil
                )
                
                let ctx = context.cgContext
                ctx.translateBy(x: 0, y: pageHeight)
                ctx.scaleBy(x: 1.0, y: -1.0)
                
                CTFrameDraw(frame, ctx)
                
                currentRange = CTFrameGetVisibleStringRange(frame)
                currentRange.location += currentRange.length
                
                drawFooter(in: context, pageNumber: currentPage, rect: pageRect)
                currentPage += 1
            }
        }
    }
    
    private static func drawHeader(in context: UIGraphicsPDFRendererContext,
                                 title: String, rect: CGRect) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        
        let titleSize = (title as NSString).size(withAttributes: titleAttributes)
        let titlePoint = CGPoint(
            x: (rect.width - titleSize.width) / 2,
            y: 50
        )
        
        title.draw(at: titlePoint, withAttributes: titleAttributes)
    }
    
    private static func drawMetadata(document: LocalDocument, in rect: CGRect) {
        let metadata = """
        Created: \(formatDate(document.timestamp))
        Last Modified: \(formatDate(document.lastModified))
        Language: \(document.language)
        """
        
        let metadataAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        metadata.draw(
            with: CGRect(x: rect.minX, y: 100, width: rect.width, height: 100),
            options: .usesLineFragmentOrigin,
            attributes: metadataAttributes,
            context: nil
        )
    }
    
    private static func drawFooter(in context: UIGraphicsPDFRendererContext,
                                 pageNumber: Int, rect: CGRect) {
        let footer = "Page \(pageNumber)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        let size = (footer as NSString).size(withAttributes: attributes)
        let point = CGPoint(
            x: (rect.width - size.width) / 2,
            y: rect.height - 30
        )
        
        footer.draw(at: point, withAttributes: attributes)
    }
    
    private static func getContentAttributes() -> [NSAttributedString.Key: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 6
                style.paragraphSpacing = 12
                return style
            }()
        ]
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
