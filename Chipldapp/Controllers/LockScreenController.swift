//
//  LockScreenController.swift
//  Chipldapp
//
//  Created by Mr.Б on 23.12.2019.
//  Copyright © 2019 KexitSoft. All rights reserved.
//

import Foundation
import MediaPlayer

class LockScreen {
        
    static func setup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        disableIrrelevantMPControls()
        addPlayCommand()
        addStopCommand()
    }
    
    static func addPlayCommand() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.isEnabled = true
        center.playCommand.addTarget{ commandEvent -> MPRemoteCommandHandlerStatus in
            ChiplRadioController.shared.play()
            return .commandFailed
        }
    }
        
    static func addStopCommand() {
        let center = MPRemoteCommandCenter.shared()
        center.stopCommand.isEnabled = true
        center.stopCommand.addTarget{ commandEvent -> MPRemoteCommandHandlerStatus in
            let player = ChiplRadioController.shared
            switch player.state {
            case .idle:
                return .commandFailed
            case .stopping:
                return .commandFailed
            default:
                ChiplRadioController.shared.stop()
                return .success
            }
        }
    }

    static func updateNowPlayingInfo(artist: String = "", title: String = "", isLiveStream: Bool = true) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = isLiveStream
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    static private func disableIrrelevantMPControls() {
        let center = MPRemoteCommandCenter.shared()
        [center.pauseCommand,
         center.togglePlayPauseCommand,
         center.nextTrackCommand,
         center.previousTrackCommand,
         center.changeRepeatModeCommand,
         center.changeShuffleModeCommand,
         center.changePlaybackRateCommand,
         center.seekBackwardCommand,
         center.seekForwardCommand,
         center.skipBackwardCommand,
         center.skipForwardCommand,
         center.changePlaybackPositionCommand,
         center.ratingCommand,
         center.likeCommand,
         center.dislikeCommand,
         center.bookmarkCommand].forEach {
            $0.addTarget{(commandEvent) -> MPRemoteCommandHandlerStatus in
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            $0.isEnabled = false
        }
    }
 
    static func clear() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

}
