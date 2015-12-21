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