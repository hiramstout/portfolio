//
//  Collections.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/26/22.
//

import Foundation
import CoreData

extension DACollection {
    static let unassignedTitle: String = "Default"
    static var unassigned: DACollection?
    
    convenience init(
        context: NSManagedObjectContext,
        category: DACategory?,
        folder: DAFolder? = nil,
        title: String = ""
    ) {
        self.init(context: context)
        self.title = title
        self.category = category
        self.folder = folder
        createTime = .now
        updateTime = .now
        cdID = UUID()
    }
    
    var title: String {
        get { cdTitle ?? "" }
        set {
            cdTitle = newValue
            cdUpdateTime = .now
        }
    }
    // TODO: displayTitle
    var createTime: Date {
        get { cdCreateTime ?? .distantPast }
        set {
            cdCreateTime = newValue
            cdUpdateTime = newValue
        }
    }
    var updateTime: Date {
        get { cdUpdateTime ?? .distantPast }
        set { cdUpdateTime = newValue}
    }
    var items: [DAItem] {
        get {
            let itemSet = nsItems as? Set<DAItem> ?? []
            return itemSet.sorted(by: {$0.title > $1.title})
        }
        set {
            nsItems = NSSet(array: newValue)
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
    
    // TODO: Type [Project, AOR, etc.]
}
