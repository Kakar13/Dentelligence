//
//  Model.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import Foundation
import SwiftData

// Define response object structure
struct Response: Codable {
    let sessionID: String
    let prompt: String
    let output: String
}

@Model
class Patient {
    var id: String
    var name: String
    var dateOfBirth: Date
    var gender: String
    var treatments: [Treatment]
    
    init(name: String, dateOfBirth: Date, gender: String, treatments: [Treatment] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.treatments = treatments
    }
}


@Model
class Treatment {
    var id: String
    var name: String
    var transcription: String
    var audioFilePath: String?
    var pdfFilePath: String?
    var date: Date
    var patient: Patient?
    
    init(name: String, transcription: String = "", date: Date = Date()) {
        self.id = UUID().uuidString
        self.name = name
        self.transcription = transcription
        self.date = date
    }
    
    var audioURL: URL? {
        guard let path = audioFilePath else { return nil }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(path)
    }
    
    var pdfURL: URL? {
        guard let path = pdfFilePath else { return nil }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(path)
    }
}
