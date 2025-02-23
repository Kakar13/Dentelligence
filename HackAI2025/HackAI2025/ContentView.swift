
// MARK: - Models
import SwiftData
import Foundation
import SwiftUI
import SwiftWhisper

class WhisperTranscriptionService {
    static let shared = WhisperTranscriptionService() // Singleton
    
    private var whisper: Whisper?
    
    private init() { // Make initializer private for singleton
        guard let modelPath = Bundle.main.path(forResource: "ggml-base.en", ofType: "bin") else {
            print("Whisper model not found!")
            return
        }
        whisper = Whisper(fromFileURL: URL(fileURLWithPath: modelPath))
    }
    
    func transcribe(audioURL: URL, completion: @escaping (String) -> Void) {
        guard let whisper = whisper else {
            print("Whisper model not loaded!")
            return
        }
        
        convertAudioToPCM(fileURL: audioURL) { result in
            switch result {
            case .success(let audioFrames):
                Task {
                    do {
                        let segments = try await whisper.transcribe(audioFrames: audioFrames)
                        let transcription = segments.map(\.text).joined()
                        DispatchQueue.main.async {
                            completion(transcription)
                        }
                    } catch {
                        print("Whisper transcription failed: \(error)")
                        DispatchQueue.main.async {
                            completion("Transcription failed.")
                        }
                    }
                }
                
            case .failure(let error):
                print("Audio conversion failed: \(error)")
                completion("Audio processing failed.")
            }
        }
    }
}

import AudioKit

func convertAudioToPCM(fileURL: URL, completion: @escaping (Result<[Float], Error>) -> Void) {
    var options = FormatConverter.Options()
    options.format = .wav
    options.sampleRate = 16000
    options.bitDepth = 16
    options.channels = 1
    options.isInterleaved = false

    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    let converter = FormatConverter(inputURL: fileURL, outputURL: tempURL, options: options)
    converter.start { error in
        if let error {
            completion(.failure(error))
            return
        }

        let data = try! Data(contentsOf: tempURL) // Handle error properly

        let floats = stride(from: 44, to: data.count, by: 2).map {
            return data[$0..<$0 + 2].withUnsafeBytes {
                let short = Int16(littleEndian: $0.load(as: Int16.self))
                return max(-1.0, min(Float(short) / 32767.0, 1.0))
            }
        }

        try? FileManager.default.removeItem(at: tempURL)

        completion(.success(floats))
    }
}





// MARK: - Updated Models
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

// MARK: - Services
import AVFoundation
import Speech
import PDFKit

import AVFoundation
import SwiftWhisper

class AudioRecordingService: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let whisperService = WhisperTranscriptionService.shared
//    private let whisperService = WhisperTranscriptionService()

    @Published var isRecording = false
    @Published var transcribedText = ""

    func startRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Define recording file location
        let tempDirectory = FileManager.default.temporaryDirectory
        let audioFilename = tempDirectory.appendingPathComponent("recording.m4a")
        recordingURL = audioFilename

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000, // Whisper requires 16kHz audio
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.record()
        isRecording = true
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        return recordingURL
    }

    func transcribeRecording(completion: @escaping (String) -> Void) {
        guard let recordingURL else {
            completion("No recording found.")
            return
        }

        whisperService.transcribe(audioURL: recordingURL) { result in
            DispatchQueue.main.async {
                self.transcribedText = result
                completion(result)
            }
        }
    }
}


class AudioPlayerService: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    private var timer: Timer?
    
    override init() {
        super.init()
    }
    
    func startPlayback(url: URL) {
        // Stop any existing playback first
        stopPlayback()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            
            audioPlayer?.play()
            isPlaying = true
            
            // Start timer for updating current time
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.currentTime = self?.audioPlayer?.currentTime ?? 0
            }
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        timer?.invalidate()
        timer = nil
        currentTime = 0
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
        timer = nil
        // Stop the audio engine completely
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("Audio Engine Stopped Successfully")
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    deinit {
        stopPlayback()
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.timer?.invalidate()
            self?.timer = nil
            self?.currentTime = 0
        }
    }
}

import UIKit
import PDFKit

class PDFGenerator {
    static func generatePDF(from treatment: Treatment) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Dentology",
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


import SwiftUI

struct HomeView: View {
    var patient = Patient(name: "John Doe", dateOfBirth: Date(), gender: "Male", treatments: [])
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                // App Title
                Text("Dentology")
                    .font(.largeTitle)
                    .bold()
                
                // Logo Image
                Image("tooth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                
                Spacer()
                
                // Navigation Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: NewReportView(patient: patient)) {
                        Label("New Report", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ReportsListView()) {
                        Label("View Reports", systemImage: "list.bullet.clipboard")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}


// MARK: - NewReportView
struct NewReportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var patientName = ""
    @State private var selectedTreatment = "Root Canal"
    @State private var selectedGender = "Male"
    @State private var dob = Date()
    @State private var navigate = false
    let patient: Patient
    
    let treatments = ["Root Canal", "Cavities", "Orthodontics"]
    let sex = ["Male", "Female"]
    
    var body: some View {
        Form {
            Section("Patient Information") {
                TextField("Patient Name", text: $patientName)
                
                DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Sex", selection: $selectedGender) {
                    ForEach(sex, id: \.self) { gender in
                        Text(gender).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Picker("Treatment", selection: $selectedTreatment) {
                ForEach(treatments, id: \.self) { treatment in
                    Text(treatment)
                }
            }
            .pickerStyle(.menu)
            
            Section {
                Button(action: {
                    navigate = true
                }) {
                    Text("Begin")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(patientName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(patientName.isEmpty)
                .navigationDestination(isPresented: $navigate) {
                    // Create a new patient with the entered information
                    RecordingView(
                        patient: Patient(
                            name: patientName,
                            dateOfBirth: dob,
                            gender: selectedGender
                        ),
                        treatmentName: selectedTreatment
                    )
                }
            }
        }
        .navigationTitle("New Report")
    }
}

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
                Text(modelResponse.isEmpty ? transcribedText : modelResponse)
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
                                audioService.transcribeRecording { result in
                                    Task {
                                        transcribedText = result
                                        await generateModelResponse() // Send to AWS after transcription
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


struct ReportPreviewView: View {
    let treatment: Treatment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let pdfURL = treatment.pdfURL {
                PDFKitView(url: pdfURL)
            } else {
                Text("Error generating PDF")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
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
}

// Updated AudioPlayerView with a more compact design
struct AudioPlayerView: View {
    @StateObject private var audioPlayer = AudioPlayerService()
    let audioURL: URL
    
    var body: some View {
        VStack(spacing: 8) {
            if audioPlayer.isPlaying {
                ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration) {
                    HStack {
                        Text(timeString(from: audioPlayer.currentTime))
                        Spacer()
                        Text(timeString(from: audioPlayer.duration - audioPlayer.currentTime))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button(action: {
                    if audioPlayer.isPlaying {
                        audioPlayer.pausePlayback()
                    } else {
                        audioPlayer.startPlayback(url: audioURL)
                    }
                }) {
                    Label(
                        audioPlayer.isPlaying ? "Pause" : "Play Recording",
                        systemImage: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if audioPlayer.isPlaying {
                    Button(action: {
                        audioPlayer.stopPlayback()
                    }) {
                        Label("Stop", systemImage: "stop.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onDisappear {
            audioPlayer.stopPlayback()
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ReportsListView: View {
    @Query private var patients: [Patient]
    @State private var selectedTreatment: Treatment?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(patients) { patient in
                Section {
                    ForEach(patient.treatments) { treatment in
                        HStack {
                            NavigationLink {
                                VStack {
                                    if let pdfURL = treatment.pdfURL {
                                        PDFKitView(url: pdfURL)
                                    } else {
                                        Text("PDF not available")
                                    }
                                    
                                    if let audioURL = treatment.audioURL {
                                        AudioPlayerView(audioURL: audioURL)
                                            .padding()
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(treatment.name)
                                        .font(.headline)
                                    
                                    Text(dateFormatter.string(from: treatment.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Reports")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let firstTreatment = patients.first?.treatments.first {
                        sharePDF(treatment: firstTreatment)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(patients.isEmpty || patients.first?.treatments.isEmpty == true)
            }
        }
    }
    
    private func sharePDF(treatment: Treatment) {
        guard let pdfURL = treatment.pdfURL else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [pdfURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

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



// MARK: - App Entry Point
@main
struct HackAI2025: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Patient.self, Treatment.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(container)
    }
}

