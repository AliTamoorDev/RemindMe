//
//  SoundsList.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI
import AVFoundation

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

struct CustomNavigationPickerView: View {
    
    @Binding var selectedStrength: Sounds
    @State var audioPlayer: AVAudioPlayer?

    let strengths: [Sounds]

    var body: some View {
        Form {
            Section {
                ForEach(0..<strengths.count){ index in
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
