//
//  FileManagerService.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import SwiftData

// MARK: - File Manager Service
class FileManagerService {
    static let shared = FileManagerService()
    
    private init() {}
    
    private var documentDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Create a unique directory for each treatment
    func createTreatmentDirectory(treatmentId: String) -> URL {
        let treatmentDirectory = documentDirectory.appendingPathComponent(treatmentId)
        try? FileManager.default.createDirectory(at: treatmentDirectory, withIntermediateDirectories: true)
        return treatmentDirectory
    }
    
    // Save audio file
    func saveAudioFile(from sourceURL: URL, treatmentId: String) -> URL? {
        let treatmentDirectory = createTreatmentDirectory(treatmentId: treatmentId)
        let destinationURL = treatmentDirectory.appendingPathComponent("recording.m4a")
        
        try? FileManager.default.removeItem(at: destinationURL) // Remove existing file if any
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to save audio file: \(error)")
            return nil
        }
    }
    
    // Save PDF file
    func savePDFFile(data: Data, treatmentId: String) -> URL? {
        let treatmentDirectory = createTreatmentDirectory(treatmentId: treatmentId)
        let destinationURL = treatmentDirectory.appendingPathComponent("report.pdf")
        
        do {
            try data.write(to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to save PDF file: \(error)")
            return nil
        }
    }
}
