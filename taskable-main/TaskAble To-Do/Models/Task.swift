//
//  CoreData+initializers.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/20/22.
//

import Foundation
import CoreData
import UserNotifications

extension DATask {
    convenience init(
        context: NSManagedObjectContext,
        category: DACategory? = nil,
        collection: DACollection? = nil,
        parent: DATask? = nil,
        title: String
    ) {
        self.init(context: context)
        createTime = .now
        updateTime = .now
        self.parent = parent
        self.title = title
        cdID = UUID()
        
        if let category {
            self.category = category
        } else {
            let request = DACategory.fetchRequest()
            request.predicate = NSPredicate(format: "self == %@", DACategory.unassignedCategory!)
            let result = try! context.fetch(request)
            self.category = result[0]
        }
        
        if let collection {
            self.collection = collection
        } else {
            self.collection = self.category?.unassigned
        }
    }
    
    enum Priority: Double, CaseIterable, Identifiable, Hashable {
        case low = 0.01
        case medium = 0.35
        case high = 0.69
        
        var id: Int { self.hashValue }
        
        var name: String {
            switch self {
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            }
        }
    }
    
    enum DueDate: Codable, RawRepresentable, Hashable {
        typealias RawValue = Data
        
        case strict(Date)
        case flexible(TimeInterval, DaysOfWeek?)
        
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
    
    // notes
    var notes: String {
        get {
            cdNotes ?? ""
        }
        set {
             cdNotes = newValue
        }
    }
    
    // children
    var children: [DATask] {
        get {
            let taskSet = nsChildren as? Set<DATask> ?? []
            let tasks = taskSet.sorted(by: {$0.title > $1.title})
            return tasks
        }
        set {
            nsChildren = NSSet(array: newValue)
        }
    }
    
    // duration
    var duration: TimeInterval? {
        get {
            if cdDuration == 0 {
                return nil
            } else {
                return TimeInterval(cdDuration)
            }
        }
        set {
            if let newValue {
                cdDuration = newValue
            } else {
                cdDuration = 0
            }
        }
    }
    
    // Priority
    var priority: Priority? {
        get {
            Priority(rawValue: rawPriority)
        }
        set {
            self.rawPriority = newValue?.rawValue ?? 0.0
        }
    }
    
    // DueDate
    var dueDate: DueDate? {
        get {
            if let rawDueDate {
                return DueDate(rawValue: rawDueDate)
            } else {
                return nil
            }
        }
        set {
            rawDueDate = newValue?.rawValue
        }
    }
    
    // Repeating
    var repeating: Repeating? {
        get {
            if let rawRepeating {
                return Repeating(rawValue: rawRepeating)
            } else {
                return nil
            }
        }
        set {
            rawRepeating = newValue?.rawValue
        }
    }
    var reminders: [Date] {
        get {
            cdReminders ?? []
        }
        set {
            
            cdReminders = newValue
        }
    }
    
    
    
    
    func addReminderNotification(for date: Date) {
        
        if Self.authorizedForUN {
            let center = UNUserNotificationCenter.current()
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
                repeats: false
            )
            
            let content = UNMutableNotificationContent()
            content.title = title
            
            // Change reminder text whenever due date is changed
            switch dueDate {
            case .strict(let dueDate):
                switch date.distance(to: dueDate) {
                case let distance where distance < TimeInterval.minute:
                    content.body = "Due now"
                case let distance where distance < TimeInterval.hour:
                    content.body = "Due in \(Int(distance/60)) min"
                case let distance where distance < TimeInterval.day:
                    content.body = "Due at \(date.formatted(date: .omitted, time: .shortened))"
                case let distance where distance > TimeInterval.day:
                    content.body = "Due \(date.formatted(date: .long, time: .shortened))"
                default:
                    content.body = ""
                }
                
            default:
                content.body = ""
            }
            
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(
                identifier: date.id.description,
                content: content,
                trigger: trigger)
            
            center.add(request) { result in
                switch result {
                case .none:
                    NSLog("notification added")
                case .some(let error):
                    NSLog("\(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func removeReminderNotification(for date: Date) {
        if Self.authorizedForUN {
            let center = UNUserNotificationCenter.current()
            
            center.removePendingNotificationRequests(withIdentifiers: [date.id.description])
        }
    }
}
