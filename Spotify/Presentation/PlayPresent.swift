//
//  PlayPresent.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//


import Foundation
import UIKit
import AVFoundation

protocol PlayDataSource: AnyObject {
    var songName: String? { get }
    var subtitleName: String? { get }
    var imageURL: URL? { get }
}

final class PlayPresent {
    
    static let shared = PlayPresent()
    
    private var track: Tracks?
    private var tracks = [Tracks]()
    var index = 0
    
    var currentlyPlaying: Tracks? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let player = self.queuePlayer, !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    
    var playVC: PlayVC?
    
    var player: AVPlayer?
    var queuePlayer: AVQueuePlayer?
    
    func startPlaying(from viewController: UIViewController, track: Tracks) {
        guard let url = URL(string: track.preview_url ?? "") else { return }
        
        player = AVPlayer(url: url)
        player?.volume = 0.5
        self.track = track
        self.tracks = []
        let vc = PlayVC()
        configurePlayVC(vc)
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playVC = vc
    }
    
    func startPlaying(from vc: UIViewController, tracks: [Tracks]) {
        self.tracks = tracks
        self.track = nil
        let items: [AVPlayerItem] = tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return AVPlayerItem(url: url)
        }
        self.queuePlayer = AVQueuePlayer(items: items)
        self.queuePlayer?.volume = 0.5
        self.queuePlayer?.play()
        let newVC = PlayVC()
        configurePlayVC(newVC)
        vc.present(UINavigationController(rootViewController: newVC), animated: true, completion: nil)
        self.playVC = newVC
    }
    
    private func configurePlayVC(_ vc: PlayVC) {
        vc.title = currentlyPlaying?.name
        vc.dataSource = self
        vc.delegate = self
    }
}

extension PlayPresent: PlayVCDelegate {
    func playPausebuttonTouched() {
        if let player = player {
            handlePlayback(for: player)
        } else if let player = queuePlayer {
            handlePlayback(for: player)
        }
    }
    
    func forwardButtonTouched() {
        if tracks.isEmpty {
            player?.pause()
        } else if let player = queuePlayer {
            queuePlayer?.advanceToNextItem()
            index += 1
            playVC?.refreshUI()
        }
    }
    
    func backwardsButtonTouched() {
        if tracks.isEmpty {
            player?.pause()
            player?.play()
        } else if let firstItem = queuePlayer?.items().first {
            resetQueuePlayer(with: firstItem)
        }
    }
    
    func didSlide(_ value: Float) {
        player?.volume = value
    }
    
    private func handlePlayback(for player: AVPlayer) {
        if player.timeControlStatus == .playing {
            player.pause()
        } else if player.timeControlStatus == .paused {
            player.play()
        }
    }
    
    private func resetQueuePlayer(with item: AVPlayerItem) {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        queuePlayer = AVQueuePlayer(items: [item])
        queuePlayer?.play()
        queuePlayer?.volume = 0.5
    }
}

extension PlayPresent: PlayDataSource {
    var songName: String? {
        return currentlyPlaying?.name
    }
    
    var subtitleName: String? {
        return currentlyPlaying?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentlyPlaying?.album?.images.first?.url ?? "")
    }
}

