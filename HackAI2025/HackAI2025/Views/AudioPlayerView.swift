//
//  AudioPlayerView.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import SwiftData
import AVFoundation

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
