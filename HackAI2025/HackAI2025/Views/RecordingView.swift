//
//  RecordingView.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import SwiftData


struct RecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingReport = false
    @State private var currentTreatment: Treatment?
    @State private var transcribedText = ""
    @State private var modelResponse: String = ""
    @State private var isLoading: Bool = false
    @StateObject private var audioService = AudioRecordingService()
    private let transcriptionService = WhisperTranscriptionService.shared
    
    let patient: Patient
    let treatmentName: String
    
    var body: some View {
        VStack {
            ScrollView {
                Text(modelResponse)
                    .padding()
            }
            // Show progress view when loading
            if isLoading {
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            }

            
            if !audioService.isRecording && !transcribedText.isEmpty && !isLoading {
                Button("View Report") {
                    generateAndShowReport()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                Button(action: {
                    Task {
                        if audioService.isRecording {
                            if let audioURL = audioService.stopRecording() {
                                isLoading = true
                                audioService.transcribeRecording { result in
                                    Task {
                                       
                                        transcribedText = result
                                        await generateModelResponse() // Send to AWS after transcription
                                        isLoading = false
                                    }
                                }
                            }
                        } else {
                            try? audioService.startRecording()
                        }
                    }
                }) {
                    Image(systemName: audioService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(audioService.isRecording ? .red : .blue)
                }
                .disabled(isLoading)

                .padding()
            }
        }
        .onChange(of: modelResponse) { _, newValue in
            transcribedText = newValue
        }
        .navigationTitle("Recording")
        .navigationDestination(isPresented: $showingReport) {
            if let treatment = currentTreatment {
                ReportPreviewView(treatment: treatment)
            }
        }
    }
    
    private func transcribeWithWhisper(audioURL: URL) async -> String {
        return await withCheckedContinuation { continuation in
            transcriptionService.transcribe(audioURL: audioURL) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func generateModelResponse() async {
        
        let treatment = Treatment(name: treatmentName, transcription: transcribedText)
        isLoading = true
        modelResponse = ""

        modelResponse = await fetchResponse(treatment: treatment)
        isLoading = false
    }
    
    private func generateAndShowReport() {
        let treatment = Treatment(name: treatmentName, transcription: transcribedText)
        treatment.patient = patient
        
        if let sourceURL = audioService.stopRecording() {
            if let savedURL = FileManagerService.shared.saveAudioFile(from: sourceURL, treatmentId: treatment.id) {
                treatment.audioFilePath = "\(treatment.id)/recording.m4a"
            }
        }
        
        if let pdfData = PDFGenerator.generatePDF(from: treatment),
           let savedURL = FileManagerService.shared.savePDFFile(data: pdfData, treatmentId: treatment.id) {
            treatment.pdfFilePath = "\(treatment.id)/report.pdf"
        }
        
        modelContext.insert(patient)
        patient.treatments.append(treatment)
        
        currentTreatment = treatment
        showingReport = true
    }
}

// MARK: - Fetch Response from AWS
func fetchResponse(treatment: Treatment) async -> String {
    return await generateSectionResponse(sectionTitle: treatment.name, transcript: treatment.transcription)
}

func generateSectionResponse(sectionTitle: String, transcript: String) async -> String {
    guard let jsonData = createSectionPrompt(sectionTitle: sectionTitle, transcript: transcript) else {
        return "Error occurred while generating request body"
    }
    
    do {
        let result = try await makeAPICall(with: jsonData)
        return result.output
    } catch {
        print("Error in API call: \(error.localizedDescription)")
        return "Error occurred while generating response"
    }
}

func createSectionPrompt(sectionTitle: String, transcript: String) -> Data? {
    let formattedPrompt = ["sectionTitle": sectionTitle, "inputData": "for the \(sectionTitle) section, include the following: \(transcript)."]
    
    do {
        return try JSONSerialization.data(withJSONObject: formattedPrompt)
    } catch {
        return nil
    }
}

func makeAPICall(with jsonData: Data) async throws -> Response {
    guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"],
          let url = URL(string: apiKey) else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    let (data, _) = try await URLSession.shared.data(for: request)

    do {
        return try JSONDecoder().decode(Response.self, from: data)
    } catch {
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let output = jsonResult["output"] as? String {
            return Response(sessionID: "unknown", prompt: "unknown", output: output)
        } else {
            throw error
        }
    }
}
