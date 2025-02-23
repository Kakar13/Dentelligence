//
//  Model.swift
//  HackAI2025
//
//  Created by Mihir Joshi on 2/22/25.
//

import Foundation

// Define response object structure
struct Response: Codable {
    let sessionID: String
    let prompt: String
    let output: String
}


// Define Template Tags object
struct TemplateTag: Identifiable, Hashable {
    let id = UUID()
    let note: String
}

// Define dental procedure object
struct ProcedureObj {
    var title: String
    var tags: [TemplateTag]
    var transcription: String
    
    init(title: String, tags: [TemplateTag], transcription: String) {
        self.title = title
        self.tags = tags
        self.transcription = transcription
    }
}
