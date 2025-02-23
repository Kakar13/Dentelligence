//
//  TreatmentDetailView.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//


import SwiftUI
import PDFKit

struct TreatmentDetailView: View {
    @State var treatment: Treatment
    
    var body: some View {
        VStack {
            if let pdfURL = treatment.pdfURL {
                PDFKitView(url: pdfURL)
                    .padding()
            } else {
                Text("PDF not available")
                    .padding()
            }
            
            if let audioURL = treatment.audioURL {
                AudioPlayerView(audioURL: audioURL)
                    .padding()
            }
        }
        .navigationTitle(treatment.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if let pdfURL = treatment.pdfURL {
                        let activityVC = UIActivityViewController(
                            activityItems: [pdfURL],
                            applicationActivities: nil
                        )
                        
                        // Get the window scene for presentation
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            activityVC.popoverPresentationController?.sourceView = rootVC.view
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    // Function to share the PDF of the selected treatment
    private func sharePDF(treatment: Treatment) {
        guard let pdfURL = treatment.pdfURL else {
            return
        }

        let activityController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        
        // Since UIActivityViewController needs to be presented from a UIViewController
        // Use UIKit to present the share sheet.
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
}
