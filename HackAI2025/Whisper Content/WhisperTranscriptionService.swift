//
//  WhisperTranscriptionService.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftWhisper
import Foundation
import AudioKit

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
