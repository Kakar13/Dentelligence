//
//  PDFGenerator.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//


import UIKit
import PDFKit

class PDFGenerator {
    static func generatePDF(from treatment: Treatment) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Tooth Mechanic",
            kCGPDFContextAuthor: "Dental Professional"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Define margins with smaller top margin
        let margins = UIEdgeInsets(top: 36, left: 50, bottom: 36, right: 50)
        let textRect = pageRect.inset(by: margins)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Times New Roman Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 4
                    style.paragraphSpacing = 8
                    return style
                }()
            ]
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 4
                    style.paragraphSpacing = 4
                    style.lineBreakMode = .byWordWrapping
                    return style
                }()
            ]

            var currentY = margins.top
            
            func drawTextBlock(_ text: String, attributes: [NSAttributedString.Key: Any], isTitle: Bool = false) -> CGFloat {
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let textStorage = NSTextStorage(attributedString: attributedString)
                let layoutManager = NSLayoutManager()
                textStorage.addLayoutManager(layoutManager)
                
                let textContainer = NSTextContainer(size: CGSize(
                    width: textRect.width,
                    height: .greatestFiniteMagnitude
                ))
                textContainer.lineFragmentPadding = 0
                layoutManager.addTextContainer(textContainer)
                
                var textPosition = 0
                var localY = currentY
                
                while textPosition < attributedString.length {
                    if localY > pageHeight - margins.bottom - 20 {
                        context.beginPage()
                        localY = margins.top
                    }
                    
                    let glyphRange = layoutManager.glyphRange(forBoundingRect:
                        CGRect(x: 0, y: 0, width: textRect.width, height: pageHeight - localY - margins.bottom),
                        in: textContainer
                    )
                    
                    let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
                    
                    if characterRange.length > 0 {
                        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint(x: margins.left, y: localY))
                        
                        let fragmentRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                        localY += fragmentRect.height
                        textPosition += characterRange.length
                    } else {
                        break
                    }
                }
                
                return localY + (isTitle ? 4 : 8)
            }
            
            // Create first page
            context.beginPage()
            
            // Draw title
            currentY = drawTextBlock("Dental Treatment Report", attributes: titleAttributes, isTitle: true)
            
            // Draw patient information
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let patientInfo = [
                "Patient: \(treatment.patient?.name ?? "Unknown")",
                "Date of Birth: \(dateFormatter.string(from: treatment.patient?.dateOfBirth ?? Date()))",
                "Gender: \(treatment.patient?.gender ?? "Unknown")",
                "Treatment: \(treatment.name)",
                "Date: \(dateFormatter.string(from: treatment.date))"
            ]
            
            for info in patientInfo {
                currentY = drawTextBlock(info, attributes: bodyAttributes)
            }
            
            // Draw transcription
            currentY = drawTextBlock("Transcription:", attributes: titleAttributes, isTitle: true)
            currentY = drawTextBlock(treatment.transcription, attributes: bodyAttributes)
        }
    }
}
