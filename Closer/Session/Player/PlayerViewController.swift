//
//  PlayerViewController.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/3/22.
//

import SwiftUI
import AVKit
import FirebaseFirestore
import FirebaseStorage

struct PlayerData: Equatable {
    var isPlaying: Bool
    var playerFileName: String
    var playerStartTime: Double
    var sessionId: String
}

class PlayerViewController: ObservableObject {
    
    static var shared = PlayerViewController()
    
    let timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    let db = Firestore.firestore()
    let controlFontSize: CGFloat = 28
    let controlWidth: CGFloat = 56
    let inactiveOpacity: Double = 0.25
    
    
    @Published var player: AVAudioPlayer?
    @Published var isDownloadingFile: Bool = false
    @Published var timeElapsedIndicator = true
    // To do:
    // Find away to get this data (and receive updates) without having to store them manually
    @Published var fileOnPlayback: String?
    @Published var timeElapsed: Double = 0
    
    
    @Published var playerData: PlayerData? = nil
    var playerDataListener: ListenerRegistration? = nil
    
    func initPlayerData(for sessionId: String) {
        self.playerDataListener?.remove()
        let ref = db.collection("sessions").document(sessionId)
        self.playerDataListener = ref.addSnapshotListener { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let document = snapshot else {
                    print("Error fetching snapshots: \(err!)")
                    return
                }
                let isPlaying = document.data()?["playerIsPlaying"] as? Bool ?? false
                let playerFileName = document.data()?["playerFileName"] as? String ?? "undefined"
                let playerStartTime = document.data()?["playerStartTime"] as? Double ?? 0
                if self.playerData == nil ||
                    isPlaying != self.playerData!.isPlaying ||
                    playerFileName != self.playerData!.playerFileName ||
                    playerStartTime != self.playerData!.playerStartTime
                {
                    self.playerData = PlayerData(
                        isPlaying: isPlaying,
                        playerFileName: playerFileName,
                        playerStartTime: playerStartTime,
                        sessionId: sessionId
                    )
                    self.playPauseOnServerHandler()
                }
                
            }
        }
    }
    
    func playPauseTapHandler(fileName: String, sessionId: String) {
        if let fileOnPlayback = fileOnPlayback, fileOnPlayback == fileName {
            if let player = player, player.isPlaying {
                pauseHandler(fileName: fileName, sessionId: sessionId)
            } else {
                resumeHandler(fileName: fileName, sessionId: sessionId)
            }
        } else {
            launchHandler(fileName: fileName, sessionId: sessionId)
        }
    }
    
    func pauseHandler(fileName: String, sessionId: String) {
        let ref = db.collection("sessions").document(sessionId)
        ref.setData(
            [
                "playerIsPlaying": false,
                "playerStartTime": player?.currentTime ?? 0,
            ],
            merge: true
        ) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func resumeHandler(fileName: String, sessionId: String) {
        let ref = db.collection("sessions").document(sessionId)
        ref.setData(
            [
                "playerFileName": fileName,
                "playerIsPlaying": true,
                "playerStartTime": player?.currentTime ?? 0 // <- THE ONLY DIFFERENCE BETWEEN THIS FUNCTION & launchHandler
            ],
            merge: true
        ) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func launchHandler(fileName: String, sessionId: String) {
        let ref = db.collection("sessions").document(sessionId)
        ref.setData(
            [
                "playerFileName": fileName,
                "playerIsPlaying": true,
                "playerStartTime": 0                     // <- THE ONLY DIFFERENCE BETWEEN THIS FUNCTION & resumeHandler
            ],
            merge: true
        ) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func playPauseOnServerHandler() {
        if let playerData = playerData {
            if playerData.isPlaying {
                playOnServerHandler()
            } else {
                pauseOnServerHandler()
            }
            self.fileOnPlayback = playerData.playerFileName
        } else {
            // TODO:
            // Handle weird error
            print("No player data available.")
        }
    }
    
    func playOnServerHandler() {
        if let playerData = playerData {
            downloadFile(fileName: playerData.playerFileName) { data in
                self.play(data, at: playerData.playerStartTime)
            }
        } else {
            // TODO:
            // Handle weird error
            print("No player data available.")
        }
    }
    
    func downloadFile(fileName: String, completionHandler: @escaping (Data) -> Void) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("\(fileName).mp3")
        if let data = try? Data(contentsOf: path) {
            completionHandler(data)
        } else {
            self.isDownloadingFile = true
            Storage
                .storage()
                .reference(withPath: "audio/\(fileName).mp3")
                .getData(maxSize: 5 * 1024 * 1024)
            { data, error in
                if let error = error {
                    print("Error getting audio file data: \(error)")
                    return
                } else {
                    guard let data = data else {
                        print("Error getting audio file data: It’s nil.")
                        return
                    }
                    try? data.write(to: path) // TODO: Do catch errors
                    completionHandler(data)
                }
                self.isDownloadingFile = false
            }
        }
    }
    
    func pauseOnServerHandler() {
        if let playerData = playerData {
            if let player = player {
                player.pause()
                self.player?.currentTime = playerData.playerStartTime
                self.timeElapsed = playerData.playerStartTime
            }
        } else {
            // TODO:
            // Handle weird error
            print("No player data available.")
        }
    }
    
    func play(_ file: Data, at startTime: TimeInterval) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.player = try AVAudioPlayer(data: file)
            self.player?.prepareToPlay()
            self.player?.currentTime = startTime
            self.player?.play()
        } catch {
            print("Failed to initialize player.", error)
        }
    }
    
    func skip5(sessionId: String, backward: Bool) {
        let multiplier: Double = backward ? -1 : 1
        let ref = db.collection("sessions").document(sessionId)
        if let player = player {
            var result = player.currentTime + (5 * multiplier)
            if !player.isPlaying {
                if result < 0 {
                    result = 0
                } else if result >= player.duration {
                    result = player.duration - 1
                }
                timeElapsed = result
            }
            
            ref.setData(
                [
                    "playerStartTime": result
                ],
                merge: true
            ) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                }
            }
        }
    }
    
    func restart(sessionId: String) {
        let ref = db.collection("sessions").document(sessionId)
        if let isPlaying = player?.isPlaying, !isPlaying {
            timeElapsed = 0
        }
        ref.setData(
            [
                "playerStartTime": 0
            ],
            merge: true
        ) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func quitPlayer() {
        if let player = player, player.isPlaying {
            player.stop()
            fileOnPlayback = nil
            timeElapsed = 0
        }
    }
}
