//
//  SoundsList.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI
import AVFoundation

// Screen for customize selection of sounds for a reminder
struct CustomNavigationPicker: View {

    var strengths: [Sounds]
    
    @Binding var selectedStrength: Sounds
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: CustomNavigationPickerView(selectedStrength: $selectedStrength, strengths: strengths)) {
                        HStack {
                            Text("Sound")
                            Spacer()
                            Text(selectedStrength.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}

// Widget for customize selection of sounds for a reminder
struct CustomNavigationPickerView: View {
    
    @Binding var selectedStrength: Sounds
    @State var audioPlayer: AVAudioPlayer?

    let strengths: [Sounds]

    var body: some View {
        Form {
            Section {
                ForEach(0..<strengths.count, id: \.self){ index in
                    HStack {
                        Button(action: {
                            selectedStrength = strengths[index]
                            if selectedStrength == strengths[index] {
                                
                                playAudio(fileName: selectedStrength.stringValue)
                            }
                        }) {
                            HStack{
                                Text(strengths[index].rawValue)
                                    .foregroundColor(Color(.label))
                                Spacer()
                                if selectedStrength == strengths[index] {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
    
    // To play a audio upon selecting a sound
    func playAudio(fileName: String) {
            guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
                print("Audio file not found")
                return
            }
            do {
                audioPlayer?.stop()
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
}


#Preview {
    CustomNavigationPicker(strengths: Sounds.allCases, selectedStrength: .constant(Sounds.jollyRing))
}
