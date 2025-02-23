//
//  PDFKitView.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import PDFKit


struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true // To fit the content in the view
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}
