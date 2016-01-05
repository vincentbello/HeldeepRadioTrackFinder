//
//  Helpers.swift
//  HeldeepRadioTrackFinder
//
//  Created by Vincent Bello on 12/20/15.
//  Copyright © 2015 Vincent Bello. All rights reserved.
//

func secondsToHoursMinutesSeconds(s: Int) -> (Int, Int, Int) {
    return (s / 3600, (s % 3600) / 60, (s % 3600) % 60)
}

func formatToTimestamp(seconds: Int) -> String {
    let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
    
    return "\(h > 0 ? "\(h):" : "")\(m > 0 ? String(format: "%02d", m) : "0"):\(String(format: "%02d", s))"
}

func leftIconRightText(icon: UIImage, color: UIColor, text: String) -> NSAttributedString {
    let attachment = NSTextAttachment()
    attachment.bounds = CGRectMake(0, -2, 15, 15)
    attachment.image = icon
    let attachmentString = NSAttributedString(attachment: attachment)
    let str = NSMutableAttributedString(attributedString: attachmentString)
    let textStr = NSAttributedString(string: " \(text)", attributes: [NSForegroundColorAttributeName: color])
    str.appendAttributedString(textStr)
    return str
}

func getTrackIndexFromArray(seconds: Int, tracks: [Track]) -> Int? {
    for (index, track) in tracks.enumerate() {
        if (index + 1 < tracks.count) {
            let nextTrack = tracks[index + 1]
            if (seconds >= track.timestamp && seconds < nextTrack.timestamp) {
                return index
            }
        } else { // last track
            if (track.timestamp > 0 && seconds >= track.timestamp) {
                return index
            }
        }
    }
    
    return nil
}