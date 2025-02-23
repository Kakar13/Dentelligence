//
//  API.swift
//  HackAI2025
//
//  Created by Mihir Joshi on 2/22/25.
//

import Foundation

public let apiErrorMessage = "Error occurred while generating response"


// Return template tags as a single string
func createTemplateTagsString(templateTags: [TemplateTag]) -> String {
    return templateTags.map { $0.note }.joined(separator: ", ")
}


// Format the section prompt as a JSON object
func createSectionPrompt(sectionTitle: String, templateTags: [TemplateTag], transcript: String) -> Data? {
    
    // Initialize prompt
    var formattedPrompt = ["sectionTitle": sectionTitle, "inputData": transcript]
    
    if !templateTags.isEmpty {
        
        let currentSectionNotes = createTemplateTagsString(templateTags: templateTags) // converts SectionNote array to String array
        
        formattedPrompt = ["sectionTitle": sectionTitle, "inputData": "for the \(sectionTitle) section, include the following: \(transcript). Use the following section notes: \(currentSectionNotes) to fill in the appropriate information."]
    }
   
    // Return the JSON Object
    do {
        return try JSONSerialization.data(withJSONObject: formattedPrompt)
    } catch {
        return nil
    }
}


func generateSectionResponse(sectionTitle: String, templateTags: [TemplateTag], transcript: String) async -> String {
    
    // Create request body
    guard let jsonData = createSectionPrompt(sectionTitle: sectionTitle, templateTags: templateTags, transcript: transcript) else {
        return "Error occurred while generating request body"
    }
    
    // Make API call (using async/await)
    do {
        let result = try await makeAPICall(with: jsonData) // Use await here
        return result.output // Return the processed output
    } catch {
        print("Error in API call: \(error.localizedDescription)")
        return "Error occurred while generating response"
    }
}

// MARK: Make api call

func makeAPICall(with jsonData: Data) async throws -> Response {
    let api = ProcessInfo.processInfo.environment["API_KEY"]!
    let url = URL(string: api)!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody
 = jsonData

    let (data, _) = try await URLSession.shared.data(for:
 request)

    do {
        // Attempt to decode the full Response struct
        let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
        return decodedResponse
    } catch {
        // If that fails, try to extract the output from a dictionary
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let output = jsonResult["output"] as? String {
            return Response(sessionID: "unknown", prompt: "unknown", output: output)
        } else {
            // If all else fails, throw the original error
            throw error
        }
    }
}

// Used to call the API from a button
func fetchResposne(dentalProcedure: ProcedureObj) async -> String {
    
    var generatedResponse: String = ""
    
    generatedResponse = await generateSectionResponse(sectionTitle: dentalProcedure.title, templateTags: dentalProcedure.tags, transcript: dentalProcedure.transcription)
    
    return generatedResponse
}
