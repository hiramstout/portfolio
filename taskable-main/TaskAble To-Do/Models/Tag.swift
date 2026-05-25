//
//  TagType.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/22/22.
//

import Foundation
import CoreData

extension DATag {
    convenience init(
        context: NSManagedObjectContext,
        title: String,
        category: DACategory? = nil,
        parent: DATag? = nil
    ) {
        self.init(context: context)
        self.title = title
        self.parent = parent
        
        if let category {
            self.category = category
        } else {
            let request = DACategory.fetchRequest()
            request.predicate = NSPredicate(format: "self == %@", DACategory.unassignedCategory!)
            let result = try! context.fetch(request)
            self.category = result[0]
        }
        updateTime = .now
        createTime = .now
        cdID = UUID()
    }
    
    var type: TagType {
        get {
            if let rawType {
                return TagType(rawValue: rawType) ?? .other
            } else {
                return .other
            }
        }
        set {
            rawType = newValue.rawValue
        }
    }
    
    enum TagType: String, CaseIterable, Identifiable {
        case location = "Location"
        case person = "Person"
        case resource = "Resource"
        case other = "Other"
        // TODO:
        /* - Timeframe/urgency
         */
        
        var id: String {
            return self.rawValue
        }
    }
    
    var children: [DATag] {
        get {
            let tagSet = nsChildren as? Set<DATag> ?? []
            return tagSet.sorted(by: {$0.title > $1.title})
        }
        set {
            nsChildren = NSSet(array: newValue)
        }
    }
    
    var descendants: [DATag] {
        get {
            var descendants = children
            for child in children {
                descendants.append(contentsOf: child.descendants)
            }
            return descendants
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
            updateTime = .now
        }
    }
    
    var displayTitle: String {
        var displayTitle: String = self.title
        var tag = self
        while tag.parent != nil {
            displayTitle = "\(tag.parent?.title ?? "") : \(displayTitle)"
            tag = tag.parent!
        }
        return displayTitle
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

