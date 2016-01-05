//
//  PlayerView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/20/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol CurrentTrackDelegate: class {
    func updateCurrentTrack(index: Int?)
    func updateTrackCells()
}

class PlayerView: UIView {
    
    weak var delegate: CurrentTrackDelegate? = nil
    
    let artwork: MPMediaItemArtwork = MPMediaItemArtwork(image: UIImage(named: "heldeep_large")!)
    
    var episode: Episode?
    var tracks: [Track]?
    
    var player: AVPlayer = AVPlayer()
    
    var didStart: Bool = false
    
    var isPlaying: Bool = false
    var shouldRestart: Bool = false
    
    var currentTrackIndex: Int? = -1
    
    var audioTimer: NSTimer?
//    var secondsPlayed: Int = 0
    
    var progressBarX: CGFloat?

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var progressTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timeBarView: UIView!
    @IBOutlet weak var elapsedTimeBarView: UIView!

    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var progressBarTickerView: UIView!
    
    @IBAction func onActionButtonTapped(sender: AnyObject) {
        toggleActions()
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        layer.addBorder(.Bottom, color: UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0), thickness: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitialization()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitialization()
    }
    
    func commonInitialization() {
        let view = NSBundle.mainBundle().loadNibNamed("PlayerView", owner: self, options: nil).first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func configureFor(episode: Episode, currentlyPlaying: Bool = false) {
        self.episode = episode
        
        let (h, m, s) = secondsToHoursMinutesSeconds(episode.duration / 1000)
        totalTimeLabel.text = "\(h > 0 ? "\(h):" : "")\(String(format: "%02d", m)):\(String(format: "%02d", s))"
        progressBarX = progressBarView.center.x
        if #available(iOS 9.0, *) {
            progressTimeLabel.font = UIFont.monospacedDigitSystemFontOfSize(11, weight: UIFontWeightRegular)
        }
        
        // Configure audio player
        
        let playerUrl = NSURL(string: episode.audioUrl())
        let playerItem = AVPlayerItem(URL: playerUrl!)
        
        if let currentPlayer = appDelegate().player {
            player = currentPlayer
            print("retrieved global player")
            
            if (currentlyPlaying) {
                progressBarView.alpha = 0 // will be animated to 1 when view appears
                let seconds = player.currentTime().seconds
                print("did update to saved state")
                updateSecondsPlayed(seconds)
                play()
            } else {
                player.pause()
                player.replaceCurrentItemWithPlayerItem(playerItem)
            }
            
        } else {
            player = AVPlayer(playerItem: playerItem)
        }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        appDelegate().player = player
        
        // Configure gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didPanProgressBar:")
        progressBarView.gestureRecognizers = [panRecognizer]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()        
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: "play")
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: "pause")
    }
    
    func configureProgressBar() {
        let seconds = player.currentTime().seconds
        updateProgressBar(seconds)
        UIView.animateWithDuration(0.2) {_ in
            self.progressBarView.alpha = 1.0
        }
    }
    
    func updateTimer() {
        let seconds = player.currentTime().seconds
        updateSecondsPlayed(seconds)
        updateCurrentTrack(seconds)
        
        // Update timeBarView position
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.updateProgressBar(seconds)
        }
    }
    
    func updateCurrentTrack(seconds: Double) {
        if (tracks != nil) {
            let index = getTrackIndexFromArray(Int(seconds), tracks: tracks!)
            if (currentTrackIndex != index) {
                delegate?.updateCurrentTrack(index)
                currentTrackIndex = index
            }
        }
    }
    
    func resetCurrentTrack() {
        currentTrackIndex = -1
        delegate?.updateTrackCells()
    }
    
    func updateProgressBar(seconds: Double) {
        let fraction = CGFloat(seconds) / CGFloat(episode!.duration / 1000)
        if (fraction <= 1) {
            let timeBarOrigin = timeBarView.frame.origin.x
            let timeBarWidth = timeBarView.frame.width
            let addedWidth = fraction * timeBarWidth
            let newX = timeBarOrigin + addedWidth
            
            self.elapsedTimeBarView.frame.size.width = addedWidth
            self.progressBarView.center.x = newX
            self.progressBarX = newX
        }
    }
    
    func updateSecondsPlayed(seconds: Double) {
        progressTimeLabel.text = formatToTimestamp(Int(seconds))
    }
    
    func didFinishPlaying(notification: NSNotification) {
        updateProgressBar(player.currentTime().seconds)
        resetCurrentTrack()
        audioTimer?.invalidate()
        isPlaying = false
        actionButton.setBackgroundImage(UIImage(named: "restart"), forState: .Normal)
        shouldRestart = true
    }
    
    func didPanProgressBar(recognizer: UIPanGestureRecognizer) {
        if (player.rate > 0) {
            audioTimer?.invalidate()
            player.pause()
        }
        let translation = recognizer.translationInView(self)
        let originX = timeBarView.frame.origin.x
        var amountMoved: CGFloat
        
        if (translation.x < 0) {
            amountMoved = max(progressBarX! + translation.x, originX)
        } else {
            amountMoved = min(progressBarX! + translation.x, originX + timeBarView.frame.width)
        }
        progressBarView.center.x = amountMoved
        elapsedTimeBarView.frame.size.width = amountMoved - originX
        
        let fraction = (progressBarView.center.x - originX) / CGFloat(timeBarView.frame.width)
        let seconds = Double(fraction * CGFloat(episode!.duration / 1000))
        updateSecondsPlayed(seconds)
        
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            goToTimestamp(seconds, shouldPlay: isPlaying)
        }
    }
    
    func goToTimestamp(seconds: Double, shouldPlay: Bool) {
        if (shouldRestart) {
            actionButton.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
            shouldRestart = false
        }
        updateProgressBar(seconds)
        updateSecondsPlayed(seconds)
        
        player.seekToTime(CMTimeMakeWithSeconds(seconds, 1000)) {_ in
            if (shouldPlay) {
                self.play()
            }
        }
    }
    
    func play() {
        print("playing")
        audioTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(audioTimer!, forMode: NSRunLoopCommonModes)
        
        player.play()
        updateCurrentTrack(player.currentTime().seconds)
        isPlaying = true
        
        if (!didStart) {
            let trackInfo: Dictionary = [
                MPMediaItemPropertyTitle: episode!.title,
                MPMediaItemPropertyArtist: "Oliver Heldens",
                MPMediaItemPropertyArtwork: artwork,
                MPNowPlayingInfoPropertyPlaybackRate: 1.0,
                MPMediaItemPropertyPlaybackDuration: NSNumber(integer: episode!.duration / 1000)
                
            ]
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = trackInfo
            
            didStart = true
        }
        setTrackInfoPlaybackRate(1.0)
        
        // UI updates
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.actionButton.setBackgroundImage(UIImage(named: "pause"), forState: .Normal)
            self.progressBarTickerView.backgroundColor = UIColor.whiteColor()
            self.elapsedTimeBarView.alpha = 0.8
        }
    }
    
    func pause() {
        print("pausing")
        audioTimer?.invalidate()
        player.pause()
        isPlaying = false
        resetCurrentTrack()
        
        setTrackInfoPlaybackRate(0.0)
        
        // UI updates
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.actionButton.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
            self.progressBarTickerView.backgroundColor = UIColor.lightGrayColor()
            self.elapsedTimeBarView.alpha = 0.5
        }
    }
    
    func reset() {
        updateProgressBar(0)
        updateSecondsPlayed(0)
        shouldRestart = false
        isPlaying = false
    }
    
    func restart() {
        reset()
        player.seekToTime(CMTimeMakeWithSeconds(0, 1000)) {_ in
            self.play()
        }
    }
    
    func toggleActions() {
        if (shouldRestart) {
            restart()
        } else if (isPlaying) {
            pause()
        } else {
            play()
        }
    }
    
    func setTrackInfoPlaybackRate(rate: Double) {
        var trackInfo: Dictionary? = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo
        trackInfo![MPNowPlayingInfoPropertyPlaybackRate] = rate
        trackInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = trackInfo
    }
}
