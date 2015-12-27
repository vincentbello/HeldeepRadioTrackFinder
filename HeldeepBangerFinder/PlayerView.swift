//
//  PlayerView.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/20/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    var episode: Episode?
    var player: AVPlayer = AVPlayer()
    
    var isPlaying: Bool = false
    var shouldRestart: Bool = false
    
    var audioTimer: NSTimer?
//    var secondsPlayed: Int = 0
    
    var progressBarX: CGFloat?

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var progressTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timeBarView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    
    @IBAction func onActionButtonTapped(sender: AnyObject) {
        if (shouldRestart) {
            restart()
        } else if (isPlaying) {
            pause()
        } else {
            play()
        }
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
                print("is currently playing")
                goToTimestamp(player.currentTime().seconds, shouldPlay: true)
            } else {
                print("this isn't currently playing")
                player.pause()
                player.replaceCurrentItemWithPlayerItem(playerItem)
            }
            
        } else {
            print("creating new player")
            player = AVPlayer(playerItem: playerItem)
        }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        appDelegate().player = player
        
        // Configure gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didPanProgressBar:")
        progressBarView.gestureRecognizers = [panRecognizer]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    func updateTimer() {
        let seconds = player.currentTime().seconds
        updateSecondsPlayed(seconds)
        
        // Update timeBarView position
        updateProgressBar(seconds)
    }
    
    func updateProgressBar(seconds: Double) {
        let fraction = CGFloat(seconds) / CGFloat(episode!.duration / 1000)
        if (fraction <= 1) {
            let timeBarOrigin = timeBarView.frame.origin.x
            let timeBarWidth = timeBarView.frame.width
            let newX = timeBarOrigin + (fraction * timeBarWidth)
            
            UIView.animateWithDuration(0.2) {_ in
                self.progressBarView.center.x = newX
                self.progressBarX = newX
            }
            
            
        }
    }
    
    func updateSecondsPlayed(seconds: Double) {
        let (h, m, s) = secondsToHoursMinutesSeconds(Int(seconds))
        progressTimeLabel.text = "\(h > 0 ? "\(h):" : "")\(m > 0 ? String(format: "%02d", m) : "0"):\(String(format: "%02d", s))"
    }
    
    func didFinishPlaying(notification: NSNotification) {
        updateProgressBar(player.currentTime().seconds)
        audioTimer?.invalidate()
        isPlaying = false
        actionButton.setBackgroundImage(UIImage(named: "restart"), forState: .Normal)
        shouldRestart = true
    }
    
    func didPanProgressBar(recognizer: UIPanGestureRecognizer) {
        print("panning")
        if (player.rate > 0) {
            audioTimer?.invalidate()
            player.pause()
        }
        let translation = recognizer.translationInView(self)
        if (translation.x < 0) {
            let minX = timeBarView.frame.origin.x
            progressBarView.center.x = max(progressBarX! + translation.x, minX)
        } else {
            let maxX = timeBarView.frame.origin.x + timeBarView.frame.width
            progressBarView.center.x = min(progressBarX! + translation.x, maxX)
        }
        let fraction = (progressBarView.center.x - timeBarView.frame.origin.x) / CGFloat(timeBarView.frame.width)
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
        
        audioTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(audioTimer!, forMode: NSRunLoopCommonModes)
        
        player.play()
        actionButton.setBackgroundImage(UIImage(named: "pause"), forState: .Normal)
        isPlaying = true
    }
    
    func pause() {
        audioTimer?.invalidate()
        player.pause()
        actionButton.setBackgroundImage(UIImage(named: "play"), forState: .Normal)
        isPlaying = false
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
    
}
