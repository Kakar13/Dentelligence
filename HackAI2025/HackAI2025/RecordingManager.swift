////
////  RecordingManager.swift
////  HackAI2025
////
////  Created by Vikas Kakar on 2/22/25.
////
//
//
//import SwiftUI
//import Speech
//import AVFoundation
//
//// MARK: - Recording Manager
//class RecordingManager: NSObject, ObservableObject {
//    @Published var isRecording = false
//    @Published var transcribedText = ""
//    @Published var errorMessage: String?
//    
//    
//    private var audioEngine = AVAudioEngine()
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    
//    override init() {
//        super.init()
//        speechRecognizer?.delegate = self
//    }
//    
//    // Inside RecordingManager class
//    func requestPermissions() async -> Bool {
//        var hasPermissions = false
//        
//        // Request microphone permission using continuation
//        let audioStatus = await withCheckedContinuation { continuation in
//            AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                continuation.resume(returning: granted)
//            }
//        }
//        
//        // Request speech recognition permission
//        let speechStatus = await withCheckedContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                continuation.resume(returning: status == .authorized)
//            }
//        }
//        
//        hasPermissions = audioStatus && speechStatus
//        return hasPermissions
//    }
//    
//    func startRecording() {
//        // Reset any existing recording session
//        resetRecording()
//        
//        // Configure audio session
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
//            return
//        }
//        
//        // Create and configure recognition request
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else {
//            errorMessage = "Failed to create recognition request"
//            return
//        }
//        recognitionRequest.shouldReportPartialResults = true
//        
//        // Configure audio engine input
//        let inputNode = audioEngine.inputNode
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            recognitionRequest.append(buffer)
//        } 
//        
//        // Start audio engine
//        audioEngine.prepare()
//        do {
//            try audioEngine.start()
//        } catch {
//            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
//            return
//        }
//        
//        // Start recognition task
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            if let result = result {
//                self?.transcribedText = result.bestTranscription.formattedString
//            }
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//                self?.resetRecording()
//            }
//        }
//        
//        isRecording = true
//    }
//    
//    func stopRecording() {
//        // Cancel the recognition task if it's running
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        
//        // Stop the audio engine
//        audioEngine.stop()
//        audioEngine.inputNode.removeTap(onBus: 0)
//        
//        // End the recognition request
//        recognitionRequest?.endAudio()
//        recognitionRequest = nil
//        
//        isRecording = false
//    }
//    
//    private func resetRecording() {
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        recognitionRequest?.endAudio()
//        recognitionRequest = nil
//    }
//}
//
//// MARK: - Speech Recognizer Delegate
//extension RecordingManager: SFSpeechRecognizerDelegate {
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        if !available {
//            errorMessage = "Speech recognition is not available"
//        }
//    }
//}
//
//// MARK: - Recording View
//struct RecordingView: View {
//    @StateObject private var recordingManager = RecordingManager()
//    @ObservedObject var viewModel: CaseViewModel
//    @State private var showingPermissionAlert = false
//    @State private var category = ""
//    @State private var selectedSeverity: Severity = .mild
//    @EnvironmentObject private var router: Router
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Transcribed text display
//            if !recordingManager.transcribedText.isEmpty {
//                ScrollView {
//                    Text(recordingManager.transcribedText)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .frame(height: 200)
//                .background(Color(.systemBackground))
//                .cornerRadius(10)
//                .shadow(radius: 2)
//            }
//            
//            Spacer()
//            
//            // Recording button
//            Button(action: {
//                if recordingManager.isRecording {
//                    recordingManager.stopRecording()
//                    if !recordingManager.transcribedText.isEmpty {
//                        viewModel.addFinding(
//                            category: category,
//                            details: recordingManager.transcribedText,
//                            severity: selectedSeverity
//                        )
//                        recordingManager.transcribedText = ""
//                    }
//                } else {
//                    Task {
//                        let hasPermission = await recordingManager.requestPermissions()
//                        if hasPermission {
//                            recordingManager.startRecording()
//                        } else {
//                            showingPermissionAlert = true
//                        }
//                    }
//                }
//            }) {
//                Image(systemName: recordingManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                    .resizable()
//                    .frame(width: 64, height: 64)
//                    .foregroundColor(recordingManager.isRecording ? .red : .blue)
//            }
//            .padding(.bottom, 30)
//            .navigationTitle("Record Findings")
//            .toolbar {
//                Button("Generate Report") {
//                    router.navigate(to: .report)
//                }
//            }
//            .padding()
//            .alert("Permissions Required", isPresented: $showingPermissionAlert) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text("Please enable microphone and speech recognition permissions in Settings to use voice recording.")
//            }
//            .alert("Error", isPresented: .constant(recordingManager.errorMessage != nil)) {
//                Button("OK", role: .cancel) {
//                    recordingManager.errorMessage = nil
//                }
//            } message: {
//                if let errorMessage = recordingManager.errorMessage {
//                    Text(errorMessage)
//                }
//            }
//        }
//    }
//}
