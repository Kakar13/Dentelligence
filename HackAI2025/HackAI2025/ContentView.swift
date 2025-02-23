//// MARK: - ContentView.swift
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    @StateObject private var router = Router()
//    @StateObject private var viewModel = CaseViewModel()
//    
//    var body: some View {
//        NavigationStack(path: $router.path) {
//            NewCaseView(viewModel: viewModel)
//                .navigationDestination(for: Route.self) { route in
//                    switch route {
//                    case .recording:
//                        RecordingView(viewModel: viewModel)
//                    case .report:
//                        ReportView(viewModel: viewModel)
//                    }
//                }
//        }
//        .environmentObject(router)
//    }
//}
//
//// MARK: - Models.swift
//import SwiftData
//
//@Model
//final class Case {
//    var id: UUID
//    var patientName: String
//    var date: Date
//    var templateType: TemplateType
//    var findings: [Finding]
//    var reportStatus: ReportStatus
//    var notes: String
//    
//    init(patientName: String, templateType: TemplateType) {
//        self.id = UUID()
//        self.patientName = patientName
//        self.date = Date()
//        self.templateType = templateType
//        self.findings = []
//        self.reportStatus = .draft
//        self.notes = ""
//    }
//}
//
//
//@Model
//class Finding {
//    var id: UUID
//    var category: String
//    var details: String  // Changed from 'description' to avoid conflict
//    var severity: Severity
//    var timestamp: Date
//    
//    init(category: String, details: String, severity: Severity) {
//        self.id = UUID()
//        self.category = category
//        self.details = details
//        self.severity = severity
//        self.timestamp = Date()
//    }
//}
//
//// MARK: - Enums.swift
//enum TemplateType: String, Codable {
//    case cavities
//    case rootCanal
//    case orthodontics
//}
//
//enum Severity: String, Codable, CaseIterable {
//    case mild
//    case moderate
//    case severe
//}
//
//enum ReportStatus: String, Codable {
//    case draft
//    case pending
//    case completed
//}
//
//enum Route: Hashable {
//    case recording
//    case report
//}
//
//enum ReportError: Error {
//    case noCaseSelected
//    case processingError
//    case networkError
//}
//
//// MARK: - Router.swift
//class Router: ObservableObject {
//    @Published var path = NavigationPath()
//    
//    func navigate(to route: Route) {
//        path.append(route)
//    }
//    
//    func navigateBack() {
//        path.removeLast()
//    }
//    
//    func navigateToRoot() {
//        path.removeLast(path.count)
//    }
//}
//
//// MARK: - Update CaseViewModel.swift
//@MainActor
//class CaseViewModel: ObservableObject {
//    @Published var currentCase: Case?
//    @Published var errorMessage: String?
//    @Published var isLoading = false
//    
//    private let awsService = AWSService.shared
//    
//    func createNewCase(patientName: String, templateType: TemplateType) {
//        currentCase = Case(patientName: patientName, templateType: templateType)
//    }
//    
//    func addFinding(category: String, details: String, severity: Severity) {
//        guard let currentCase = currentCase else { return }
//        let finding = Finding(category: category, details: details, severity: severity)
//        currentCase.findings.append(finding)
//    }
//    
//    func generateReport() async throws -> String {
//        guard let currentCase = currentCase else {
//            throw ReportError.noCaseSelected
//        }
//        
//        isLoading = true
//        defer { isLoading = false }
////        
////        // Use the new encode method
////        let reportData = try currentCase.encode()
////        return try await awsService.generateReport(reportData)
//        return ""
//    }
//}
//
//// MARK: - AWSService.swift
//class AWSService {
//    static let shared = AWSService()
//    
//    private init() {
//        configureAWS()
//    }
//    
//    private func configureAWS() {
//        // AWS configuration code here
//        // Add your AWS credentials and configuration
//    }
//    
//    func generateReport(_ data: Data) async throws -> String {
//        // Simulate API call to AWS
//        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)  // 2 second delay
//        return "Sample Report for Patient"
//    }
//}
//
//// MARK: - Views/NewCaseView.swift
//struct NewCaseView: View {
//    @ObservedObject var viewModel: CaseViewModel
//    @EnvironmentObject private var router: Router
//    @State private var patientName = ""
//    @State private var selectedTemplate: TemplateType = .cavities
//    
//    var body: some View {
//        Form {
//            Section("Patient Information") {
//                TextField("Patient Name", text: $patientName)
//                Picker("Template Type", selection: $selectedTemplate) {
//                    Text("Cavities").tag(TemplateType.cavities)
//                    Text("Root Canal").tag(TemplateType.rootCanal)
//                    Text("Orthodontics").tag(TemplateType.orthodontics)
//                }
//            }
//            
//            Section {
//                Button("Create Case") {
//                    viewModel.createNewCase(
//                        patientName: patientName,
//                        templateType: selectedTemplate
//                    )
//                    router.navigate(to: .recording)
//                }
//                .disabled(patientName.isEmpty)
//            }
//        }
//        .navigationTitle("New Case")
//    }
//}
//
////// MARK: - Views/RecordingView.swift
////struct RecordingView: View {
////    @ObservedObject var viewModel: CaseViewModel
////    @EnvironmentObject private var router: Router
////    
////    var body: some View {
////        Group {
////            switch viewModel.currentCase?.templateType {
////            case .cavities:
////                DentalRecordingForm(
////                    title: "Cavity Assessment",
////                    categories: ["Tooth Decay", "Filling Needed", "Preventive Care"],
////                    viewModel: viewModel
////                )
////            case .rootCanal:
////                DentalRecordingForm(
////                    title: "Root Canal Assessment",
////                    categories: ["Pulp Status", "Canal Condition", "Treatment Plan"],
////                    viewModel: viewModel
////                )
////            case .orthodontics:
////                DentalRecordingForm(
////                    title: "Orthodontics Assessment",
////                    categories: ["Alignment", "Spacing", "Bite Pattern"],
////                    viewModel: viewModel
////                )
////            case .none:
////                EmptyView()
////            }
////        }
////        .navigationTitle("Record Findings")
////        .toolbar {
////            Button("Generate Report") {
////                router.navigate(to: .report)
////            }
////        }
////    }
////}
//
//// MARK: - Views/DentalRecordingForm.swift
//struct DentalRecordingForm: View {
//    let title: String
//    let categories: [String]
//    @ObservedObject var viewModel: CaseViewModel
//    @State private var selectedCategory = ""
//    @State private var details = ""
//    @State private var selectedSeverity: Severity = .mild
//    
//    var body: some View {
//        Form {
//            Section("New Finding") {
//                Picker("Category", selection: $selectedCategory) {
//                    ForEach(categories, id: \.self) { category in
//                        Text(category).tag(category)
//                    }
//                }
//                
//                TextField("Details", text: $details, axis: .vertical)
//                    .lineLimit(3...6)
//                
//                Picker("Severity", selection: $selectedSeverity) {
//                    ForEach(Severity.allCases, id: \.self) { severity in
//                        Text(severity.rawValue.capitalized).tag(severity)
//                    }
//                }
//                
//                Button("Add Finding") {
//                    viewModel.addFinding(
//                        category: selectedCategory,
//                        details: details,
//                        severity: selectedSeverity
//                    )
//                    details = ""
//                }
//                .disabled(selectedCategory.isEmpty || details.isEmpty)
//            }
//            
//            if let currentCase = viewModel.currentCase {
//                Section("Recorded Findings") {
//                    ForEach(currentCase.findings) { finding in
//                        VStack(alignment: .leading) {
//                            Text(finding.category)
//                                .font(.headline)
//                            Text(finding.details)
//                                .font(.body)
//                            Text("Severity: \(finding.severity.rawValue.capitalized)")
//                                .font(.caption)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Views/ReportView.swift
//struct ReportView: View {
//    @ObservedObject var viewModel: CaseViewModel
//    @State private var report: String?
//    @State private var error: String?
//    
//    var body: some View {
//        Group {
//            if viewModel.isLoading {
//                ProgressView("Generating Report...")
//            } else if let report = report {
//                ScrollView {
//                    Text(report)
//                        .padding()
//                }
//            } else if let error = error {
//                VStack {
//                    Text("Error generating report")
//                        .font(.headline)
//                    Text(error)
//                        .font(.body)
//                        .foregroundColor(.red)
//                }
//            } else {
//                Text("Loading...")
//            }
//        }
//        .navigationTitle("Report")
//        .task {
//            do {
//                report = try await viewModel.generateReport()
//            } catch {
//                self.error = error.localizedDescription
//            }
//        }
//    }
//}

// MARK: - Models
import SwiftData
import Foundation
import SwiftUI

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

// MARK: - Updated AudioRecordingService
class AudioRecordingService: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var recordingURL: URL?
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    
    func startRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Use a persistent file instead of a temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let audioFilename = tempDirectory.appendingPathComponent("continuous_recording.m4a")
        recordingURL = audioFilename  // Preserve the recording URL for later
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Check if a previous recording exists and append to it
        if FileManager.default.fileExists(atPath: audioFilename.path) {
            let fileHandle = try FileHandle(forWritingTo: audioFilename)
            fileHandle.seekToEndOfFile()  // Append new data at the end
        } else {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        }
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.transcribedText = result.bestTranscription.formattedString
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }

    
    func stopRecording() -> URL? {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioRecorder?.stop()
        isRecording = false
        return recordingURL  // Preserve the recorded file path instead of discarding it
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

// Update PDFGenerator to include new fields
class PDFGenerator {
    static func generatePDF(from treatment: Treatment) -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        return try? pdfRenderer.pdfData { context in
            context.beginPage()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let dobFormatter = DateFormatter()
            dobFormatter.dateStyle = .long
            
            let title = "Dental Treatment Report"
//            let patientName = "Patient: \(treatment.patient?.name ?? "Unknown")"
            let patientName = "Patient: \(treatment.patient?.name ?? "Unknown")"
            let patientDOB = "Date of Birth: \(dobFormatter.string(from: treatment.patient?.dateOfBirth ?? Date()))"
            let patientGender = "Gender: \(treatment.patient?.gender ?? "Unknown")"
            let treatmentName = "Treatment: \(treatment.name)"
            let date = "Date: \(dateFormatter.string(from: treatment.date))"
            let transcription = treatment.transcription
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Draw the title and headers with adjusted vertical spacing
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            patientName.draw(at: CGPoint(x: 50, y: 100), withAttributes: headerAttributes)
            patientDOB.draw(at: CGPoint(x: 50, y: 120), withAttributes: headerAttributes)
            patientGender.draw(at: CGPoint(x: 50, y: 140), withAttributes: headerAttributes)
            treatmentName.draw(at: CGPoint(x: 50, y: 160), withAttributes: headerAttributes)
            date.draw(at: CGPoint(x: 50, y: 180), withAttributes: headerAttributes)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            
            // Adjust the starting y-position of the transcription to account for new fields
            transcription.draw(in: CGRect(x: 50, y: 220, width: 512, height: 522),
                             withAttributes: [
                                .font: UIFont.systemFont(ofSize: 12),
                                .paragraphStyle: paragraphStyle
                             ])
        }
    }
}


// MARK: - Views
import SwiftUI

struct HomeView: View {
    var patient = Patient(name: "John Doe", dateOfBirth: Date(), gender: "Male", treatments: [])
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Dentology")
                    .font(.largeTitle)
                    .bold()
                
                
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
    @StateObject private var audioService = AudioRecordingService()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingReport = false
    @State private var currentTreatment: Treatment?
    
    let patient: Patient
    let treatmentName: String
    
    var body: some View {
        VStack {
            ScrollView {
                Text(audioService.transcribedText)
                    .padding()
            }
            
            Spacer()
            
            if !audioService.isRecording && !audioService.transcribedText.isEmpty {
                Button("View Report") {
                    generateAndShowReport()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            } else {
                Button(action: {
                    if audioService.isRecording {
                        let _ = audioService.stopRecording()
                    } else {
                        try? audioService.startRecording()
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
        .navigationTitle("Recording")
        .navigationDestination(isPresented: $showingReport) {
            if let treatment = currentTreatment {
                ReportPreviewView(treatment: treatment)
            }
        }
    }
    
    private func generateAndShowReport() {
        // Create a new treatment and set its relationship with the patient
        let treatment = Treatment(name: treatmentName, transcription: audioService.transcribedText)
        treatment.patient = patient
        
        // Save audio file if available
        if let sourceURL = audioService.stopRecording() {
            if let savedURL = FileManagerService.shared.saveAudioFile(
                from: sourceURL,
                treatmentId: treatment.id
            ) {
                treatment.audioFilePath = "\(treatment.id)/recording.m4a"
            }
        }
        
        // Generate and save PDF
        if let pdfData = PDFGenerator.generatePDF(from: treatment),
           let savedURL = FileManagerService.shared.savePDFFile(
            data: pdfData,
            treatmentId: treatment.id
           ) {
            treatment.pdfFilePath = "\(treatment.id)/report.pdf"
        }
        
        // Insert the patient into the model context if it's not already there
        modelContext.insert(patient)
        
        // Add the treatment to the patient's treatments array
        patient.treatments.append(treatment)
        
        currentTreatment = treatment
        showingReport = true
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
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
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
