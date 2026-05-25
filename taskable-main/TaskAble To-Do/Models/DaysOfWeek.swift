//
//  Days.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/13/22.
//

import Foundation

struct DaysOfWeek: OptionSet, Codable {
    let rawValue: Int
    
    static let sunday = Self(rawValue: 1 << 0)
    static let monday = Self(rawValue: 1 << 1)
    static let tuesday = Self(rawValue: 1 << 2)
    static let wednesday = Self(rawValue: 1 << 3)
    static let thursday = Self(rawValue: 1 << 4)
    static let friday = Self(rawValue: 1 << 5)
    static let saturday = Self(rawValue: 1 << 6)
    
    static let weekdays = [monday, tuesday, wednesday, thursday, friday]
    static let weekends = [sunday, saturday]
    
    func title(for day: Self) -> String? {
        switch day {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        default:
            return nil
        }
    }
}
