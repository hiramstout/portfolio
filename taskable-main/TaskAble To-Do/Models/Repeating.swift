//
//  Repeating.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/13/22.
//

import Foundation


struct Repeating: Codable, RawRepresentable {
    typealias RawValue = Data
    
    var timeFrame: TimeFrame
    var behavior: Behavior
    
    enum TimeFrame: Codable {
        case daily(Int)
        case weeklyDays(DaysOfWeek)
        case weeklyInterval(Int)
        case monthly(Int)
        case yearly(Int)
    }
    enum Behavior: Codable {
        case fromCompletion
        case fromDueDate
    }
    init(timeFrame: TimeFrame, behavior: Behavior) {
        self.timeFrame = timeFrame
        self.behavior = behavior
    }
    
    init?(rawValue: Data) {
        let decoder = PropertyListDecoder()
        var format = PropertyListSerialization.PropertyListFormat.binary
        if let value = try? decoder.decode(Self.self, from: rawValue, format: &format) {
            self = value
        } else {
            return nil
        }
        
    }
    
    var rawValue: Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        if let value = try? encoder.encode(self) {
            return value
        } else {
            return Data()
        }
    }
}
