//
//  PlayerView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/3/22.
//

import SwiftUI

struct PlayerView: View {
    
    @StateObject var viewModel = PlayerViewController.shared
    
    let fileName: String
    let sessionId: String
    
    var isActivated: Bool {
        if let fileOnPlayback = viewModel.fileOnPlayback, !viewModel.isDownloadingFile {
            return fileOnPlayback == fileName
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                
                PlayerButton(
                    iconName: "backward.end",
                    isActivated: isActivated,
                    isHero: false,
                    buttonFontSize: viewModel.controlFontSize,
                    buttonWidth: viewModel.controlWidth,
                    inactiveOpacity: viewModel.inactiveOpacity
                ) {
                    viewModel.restart(sessionId: sessionId)
                }
                
                PlayerButton(
                    iconName: "gobackward.5",
                    isActivated: isActivated,
                    isHero: false,
                    buttonFontSize: viewModel.controlFontSize,
                    buttonWidth: viewModel.controlWidth,
                    inactiveOpacity: viewModel.inactiveOpacity
                ) {
                    viewModel.skip5(sessionId: sessionId, backward: true)
                }
                
                PlayerButton(
                    iconName:
                        viewModel.isDownloadingFile ? "arrow.down.to.line.circle" :
                        isActivated && viewModel.player?.isPlaying ?? false ? "pause.circle.fill" : "play.circle.fill",
                    isActivated: !viewModel.isDownloadingFile,
                    isHero: true,
                    buttonFontSize: viewModel.controlFontSize * 2.4,
                    buttonWidth: viewModel.controlWidth * 1.2,
                    inactiveOpacity: viewModel.inactiveOpacity
                ) {
                    viewModel.playPauseTapHandler(fileName: fileName, sessionId: sessionId)
                }
                .padding(.horizontal, 12)
                
                PlayerButton(
                    iconName: "goforward.5",
                    isActivated: isActivated,
                    isHero: false,
                    buttonFontSize: viewModel.controlFontSize,
                    buttonWidth: viewModel.controlWidth,
                    inactiveOpacity: viewModel.inactiveOpacity
                ) {
                    viewModel.skip5(sessionId: sessionId, backward: false)
                }
                
                
                HStack(spacing: 0) {
                    if isActivated && !viewModel.timeElapsedIndicator {
                        Text("-")
                            .foregroundColor(.gray)
                    }
                    Button {
                        viewModel.timeElapsedIndicator.toggle()
                    } label: {
                        Text(
                            isActivated
                            ? DateComponentsFormatter
                                .positional
                                .string(
                                    from: viewModel.timeElapsedIndicator
                                    ? viewModel.timeElapsed
                                    : (viewModel.player?.duration ?? 0) - viewModel.timeElapsed
                                ) ?? "0:00"
                            : "0:00"
                        )
                        .foregroundColor(.gray)
                        .opacity(isActivated ? 1 : viewModel.inactiveOpacity)
                    }
                    .disabled(!isActivated)
                }
                .frame(width: viewModel.controlWidth)
            }
            
            if viewModel.isDownloadingFile {
                Text("Downloading audio")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            viewModel.downloadFile(fileName: fileName) { _ in }
            if let playerData = viewModel.playerData, playerData.sessionId == sessionId  {
            } else {
                viewModel.initPlayerData(for: sessionId)
            }
        }
        .onReceive(viewModel.timer) { _ in
            guard let player = viewModel.player, isActivated, player.isPlaying else {
                return
            }
            if (player.duration - player.currentTime) < 1 {
                viewModel.playPauseTapHandler(fileName: fileName, sessionId: sessionId)
                viewModel.restart(sessionId: sessionId)
                viewModel.timeElapsed = 0
            } else {
                viewModel.timeElapsed = player.currentTime
            }
        }
    }
}

struct PlayerButton: View {
    
    let iconName: String
    let isActivated: Bool
    let isHero: Bool
    
    let buttonFontSize: CGFloat
    let buttonWidth: CGFloat
    let inactiveOpacity: Double
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconName)
                .font(.system(size: buttonFontSize))
                .frame(width: buttonWidth)
                .foregroundColor(isHero ? .accentColor : .gray)
                .opacity(isActivated ? 1 : inactiveOpacity)
        }
        .disabled(!isActivated)
    }
}

extension DateComponentsFormatter {
    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
