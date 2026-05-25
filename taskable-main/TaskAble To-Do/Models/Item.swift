//
//  Item.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/17/22.
//

import Foundation
import CoreData


//protocol DAItem: Identifiable, NSFetchRequestResult {
//    associatedtype FetchedResults: NSManagedObject = Self
//    var createTime: Date? {get set}
//
//    // var updateTime
//    // var title
//    //
//
//}
//
//extension DATask: DAItem {
//
//}
//extension DAIdea: DAItem {
//
//}
//extension DAHabit: DAItem {
//
//}

/* TODO: Difference between idea and task:
 - Goal?
 - Limited fields?
 - Auto-delete after timeframe?
 - Could be used for lists (ie grocery)?
 
 TODO: Habits?
 - Does "Habit" encompass everything that would work best in this type? Such as:
   - Bills
*/

extension DAItem {
    enum Status: String, Identifiable {
        case completed
        case dropped
        case defered
        case designated // User has added a tag/group to the task to remove it from inbox
        case needsDesignation // User needs to add tag/group
        
        var id: String { self.rawValue }
    }
    
    var status: Status {
        get {
            if let currentStatus = Status(rawValue: rawStatus ?? "") {
                return currentStatus
            } else {
                rawStatus = Status.needsDesignation.rawValue
                return .needsDesignation
            }
        }
        set {
            rawStatus = newValue.rawValue
        }
    }
    
    var title: String {
        get {
            if let cdTitle {
                return cdTitle
            } else {
                cdTitle = ""
                return ""
            }
        }
        set {
            cdTitle = newValue
            cdUpdateTime = .now
        }
    }
    
    var updateTime: Date {
        get {
            if let cdUpdateTime {
                return cdUpdateTime
            } else {
                cdUpdateTime = .now
                return .now
            }
        }
        set {
            cdUpdateTime = newValue
        }
    }
    
    var createTime: Date {
        get {
            if let cdCreateTime {
                return cdCreateTime
            } else {
                cdCreateTime = .distantPast
                return .distantPast
            }
        }
        set {
            cdCreateTime = newValue
            cdUpdateTime = .now
        }
    }
    
    var tags: [DATag] {
        get {
            let tagsSet = nsTags as? Set<DATag> ?? []
            let tags = tagsSet.sorted {$0.title > $1.title}
            return tags
        }
        set {
            nsTags = NSSet(array: newValue)
        }
    }
    
    public var id: UUID {
        get {
            if let cdID {
                return cdID
            } else {
                let id = UUID()
                cdID = id
                return id
            }
        }
        set {
            cdID = newValue
        }
    }
}
