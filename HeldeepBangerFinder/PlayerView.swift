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

class PlayerView: UIView, AVAudioPlayerDelegate {
    
    weak var delegate: CurrentTrackDelegate? = nil
    
    let artwork: MPMediaItemArtwork = MPMediaItemArtwork(image: UIImage(named: "heldeep_large")!)
//    private let PlayerStatusObservingContext = UnsafeMutablePointer<Void>(bitPattern: 1)
    
    var episode: Episode?
    var tracks: [Track]?
    
    var player: AVPlayer = AVPlayer()
    var duration: Double = 0
    
    var didStart: Bool = false
    
    var isPlaying: Bool = false
    var shouldRestart: Bool = false
    var fadeLogStep: Float = 1
    
    var currentTrackIndex: Int? = -1
    
    var audioTimer: NSTimer?
    
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
    
    func configureFor(episode: Episode) {
        self.episode = episode
        
        // Configure audio player
        
        let playerUrl = NSURL(string: episode.audioUrl())
        let playerItem = AVPlayerItem(URL: playerUrl!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        if let currentPlayer = appDelegate().player {
            
            player = currentPlayer
            
            if (player.rate > 0) {
                
                progressBarView.alpha = 0 // will be animated to 1 when view appears
                updateSecondsPlayed(player.currentTime().seconds)
                toggleActionButton(true)
                play()
            } else {
                setTrackInfoPlayback(0)
                player.pause()
                player.replaceCurrentItemWithPlayerItem(playerItem)
            }

        } else {
            player = AVPlayer(playerItem: playerItem)
        }
        
        appDelegate().player = player
        
//        appDelegate().player!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: PlayerStatusObservingContext)

        // Configure gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didPanProgressBar:")
        progressBarView.gestureRecognizers = [panRecognizer]
        
        // UI
        duration = Double(episode.duration) / 1000
        totalTimeLabel.text = formatToTimestamp(Int(duration))
        progressBarX = progressBarView.center.x
        if #available(iOS 9.0, *) {
            progressTimeLabel.font = UIFont.monospacedDigitSystemFontOfSize(11, weight: UIFontWeightRegular)
        }
    }
    
    func toggleActionButton(enabled: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.actionButton.enabled = enabled
        }
    }
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        print("observing...")
//        if context == PlayerStatusObservingContext {
//            if let change = change as? [String: Int] {
//                let newChange = change[NSKeyValueChangeNewKey]!
//                switch newChange {
//                case AVPlayerItemStatus.ReadyToPlay.rawValue:
//                    print("naysh")
//                    toggleActionButton(true)
//                    UIApplication.toggleActivityIndicator(false)
//                default:
//                    toggleActionButton(false)
//                }
//            }
//            return
//        }
//        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
//    }
    
    func configureProgressBar() {
        updateProgressBar(player.currentTime().seconds)
        UIView.animateWithDuration(0.2) {_ in
            self.progressBarView.alpha = 1.0
        }
    }
    
    func updateTimer() {
        let seconds = player.currentTime().seconds
        updateSecondsPlayed(seconds)
        updateCurrentTrack(seconds)
        setTrackInfoPlayback()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Update timeBarView position
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.updateProgressBar(seconds)
        }
    }
    
    func updateCurrentTrack(seconds: Double) {
        if (tracks != nil) {
            let index = getTrackIndexFromArray(Int(seconds), tracks: tracks!)
            if (currentTrackIndex != index) {
                if (index != nil) {
                    let newTrack = tracks![index!]
                    MPNowPlayingInfoCenter.defaultCenter().updateInfo([MPMediaItemPropertyTitle: newTrack.title])
                } else {
                    MPNowPlayingInfoCenter.defaultCenter().updateInfo([MPMediaItemPropertyTitle: episode!.title])
                }
                
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
        let fraction = CGFloat(seconds) / CGFloat(duration)
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
    
    func didFinishPlaying() {
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
            setTrackInfoPlayback(0)
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
        
        let fraction = (progressBarView.center.x - originX) / CGFloat(timeBarView.frame.width)
        let seconds = Double(fraction * CGFloat(duration))
        
        dispatch_async(dispatch_get_main_queue()) {
            self.progressBarView.center.x = amountMoved
            
            self.elapsedTimeBarView.frame.size.width = amountMoved - originX
            
            self.updateSecondsPlayed(seconds)
        }
        
        switch recognizer.state {
        case .Ended:
            goToTimestamp(seconds, shouldPlay: isPlaying)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBarView.backgroundColor = UIColor.clearColor()
                self.progressBarTickerView.backgroundColor = UIColor.lightGrayColor()
            }
        case .Began:
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBarView.backgroundColor = UIColor(white: 1, alpha: 0.5)
                self.progressBarTickerView.backgroundColor = UIColor.whiteColor()
            }
        default: ()
        }
    }
    
    func goToTimestamp(seconds: Double, shouldPlay: Bool) {
        if (shouldRestart) {
            actionButton.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
            shouldRestart = false
        }
        updateProgressBar(seconds)
        updateSecondsPlayed(seconds)
        setTrackInfoPlayback(0)
        player.pause()
        
        player.seekToTime(CMTimeMakeWithSeconds(seconds, 1000)) {_ in
            if (shouldPlay) {
                self.player.volume = 0
                self.play()
                self.doVolumeFade()
            }
        }
    }
    
    func doVolumeFade() {
        if (player.volume < 1) {
            let incr = (fadeLogStep * fadeLogStep) / 1000
            player.volume += incr
            fadeLogStep += 1
            performSelector("doVolumeFade", withObject: nil, afterDelay: 0.1)
        } else {
            player.volume = 1
            fadeLogStep = 1
        }
    }
    
    func play() {
        
        // UI updates
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.actionButton.setBackgroundImage(UIImage(named: "pause"), forState: .Normal)
            self.progressBarTickerView.backgroundColor = UIColor.whiteColor()
            self.elapsedTimeBarView.alpha = 0.8
        }
        
        audioTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(audioTimer!, forMode: NSRunLoopCommonModes)
        
        setTrackInfoPlayback()
        player.play()
        updateCurrentTrack(player.currentTime().seconds)
        isPlaying = true
        
        if (!didStart) {
            initializeSessionOnFirstPlay()
            didStart = true
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Couldn't set active audio session")
        }
    }
    
    func pause() {

        // UI updates
        dispatch_async(dispatch_get_main_queue()) {_ in
            self.actionButton.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
            self.progressBarTickerView.backgroundColor = UIColor.lightGrayColor()
            self.elapsedTimeBarView.alpha = 0.5
        }
        
        audioTimer?.invalidate()
        setTrackInfoPlayback(0)
        player.pause()
        isPlaying = false
        resetCurrentTrack()
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
    
    func setTrackInfoPlayback(rate: Double = 1) {
        let toUpdate = [
            MPNowPlayingInfoPropertyPlaybackRate: rate,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime().seconds
        ]
        MPNowPlayingInfoCenter.defaultCenter().updateInfo(toUpdate)
    }
    
    func initializeSessionOnFirstPlay() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        } catch {
            print("Error setting AVAudioSession")
        }
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: "interruptAudioSession", name: AVAudioSessionInterruptionNotification, object: nil)
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.enabled = true
        commandCenter.playCommand.addTarget(self, action: "play")
        commandCenter.pauseCommand.enabled = true
        commandCenter.pauseCommand.addTarget(self, action: "pause")

        
        let trackInfo: Dictionary = [
            MPMediaItemPropertyTitle: episode!.title,
            MPMediaItemPropertyAlbumTitle: episode!.title,
            MPMediaItemPropertyArtist: "Oliver Heldens",
            MPMediaItemPropertyArtwork: artwork,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: NSNumber(double: duration)
            
        ]
        MPNowPlayingInfoCenter.defaultCenter().updateInfo(trackInfo)
    }
    
    func interruptAudioSession() {
        pause()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Couldn't set inactive audio session")
        }
    }
}
