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