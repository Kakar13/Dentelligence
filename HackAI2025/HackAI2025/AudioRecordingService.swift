//
//  AudioRecordingService.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//


// MARK: - Services
import AVFoundation
import Speech
import PDFKit
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
