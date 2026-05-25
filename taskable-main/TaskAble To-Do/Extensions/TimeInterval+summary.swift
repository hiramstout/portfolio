//
//  TimeInterval+Summary.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/20/22.
//

import Foundation

extension TimeInterval {
    static let second = TimeInterval(1)
    static let minute = second * 60
    static let hour = minute * 60
    static let day = hour * 60
    
    var summary: String {
        if self >= Self.day {
            let days = Int(floor(self/Self.day))
            return "\(days)d"
        } else if self >= Self.hour {
            let hours = Int(floor(self/Self.hour))
            return "\(hours)h"
        } else if self >= Self.minute {
            let minutes = Int(floor(self/Self.minute))
            return "\(minutes)m"
        } else {
            return "Now"
        }
    }
}
