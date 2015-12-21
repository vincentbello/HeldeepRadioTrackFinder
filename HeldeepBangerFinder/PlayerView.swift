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
    var secondsPlayed: Int = 0
    
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
    
    func configureFor(episode: Episode) {
        self.episode = episode
        
        let (h, m, s) = secondsToHoursMinutesSeconds(episode.duration / 1000)
        totalTimeLabel.text = "\(h > 0 ? "\(h):" : "")\(String(format: "%02d", m)):\(String(format: "%02d", s))"
        progressBarX = progressBarView.center.x
        
        // Configure audio player
        
//        let playerUrl = NSURL(string: episode.audioUrl())
        let playerUrl = NSURL(string: "https://api.soundcloud.com/tracks/86569568/stream?client_id=20c0a4e42940721a64391ac4814cc8c7")
        
        let playerItem = AVPlayerItem(URL: playerUrl!)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        
        // Configure gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "didPanProgressBar:")
        progressBarView.gestureRecognizers = [panRecognizer]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    func updateTimer() {
        updateSecondsPlayed(secondsPlayed + 1)
        
        // Update timeBarView position
        let fraction = CGFloat(secondsPlayed) / CGFloat(episode!.duration / 1000)
        if (fraction < 1) {
            updateCursorPosition(fraction)
        }
    }
    
    func updateCursorPosition(fraction: CGFloat) {
        let timeBarOrigin = timeBarView.frame.origin.x
        let timeBarWidth = timeBarView.frame.width
        progressBarView.center.x = timeBarOrigin + (fraction * timeBarWidth)
        progressBarX = progressBarView.center.x
    }
    
    // Only cursor position has been set
    func updateFromProgressBar(fraction: CGFloat) {
        let seconds = Int(fraction * CGFloat(episode!.duration / 1000))
        updateSecondsPlayed(seconds)
        player.seekToTime(CMTimeMakeWithSeconds(Double(seconds), 5))
    }
    
    func updateSecondsPlayed(seconds: Int) {
        secondsPlayed = seconds
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        progressTimeLabel.text = "\(h > 0 ? "\(h):" : "")\(m > 0 ? String(format: "%02d", m) : "0"):\(String(format: "%02d", s))"
    }
    
    func didFinishPlaying(notification: NSNotification) {
        updateCursorPosition(1)
        audioTimer?.invalidate()
        isPlaying = false
        actionButton.setBackgroundImage(UIImage(named: "restart"), forState: .Normal)
        shouldRestart = true
    }
    
    func didPanProgressBar(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self)
        if (translation.x < 0) {
            let minX = timeBarView.frame.origin.x
            progressBarView.center.x = max(progressBarX! + translation.x, minX)
//            progressBarX = progressBarView.center.x
        } else {
            let maxX = timeBarView.frame.origin.x + timeBarView.frame.width
            progressBarView.center.x = min(progressBarX! + translation.x, maxX)
//            progressBarX = progressBarView.center.x
        }
        
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            progressBarX = progressBarView.center.x
            let fraction = (progressBarX! - timeBarView.frame.origin.x) / CGFloat(timeBarView.frame.width)
            updateFromProgressBar(fraction)
        }
    }
    
    
    
    func play() {
        audioTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
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
    
    func restart() {
        reset()
        play()
    }
    
    func reset() {
        updateCursorPosition(0)
        secondsPlayed = 0
        player.seekToTime(CMTimeMakeWithSeconds(0, 5))
        shouldRestart = false
    }
    
}
