//
//  Folder.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/26/22.
//

import Foundation
import CoreData

extension DAFolder {
    
    convenience init(
        context: NSManagedObjectContext,
        category: DACategory,
        parent: DAFolder? = nil,
        title: String = ""
    ) {
        self.init(context: context)
        self.title = title
        self.category = category
        self.parent = parent
        createTime = .now
        updateTime = .now
        cdID = UUID()
        let unassigned = DACollection(
            context: context,
            category: category,
            title: "Default")
        unassigned.unassignedForFolder = self
        self.unassigned = unassigned
    }
    
    var title: String {
        get { cdTitle ?? "" }
        set {
            cdTitle = newValue
            cdUpdateTime = .now
        }
    }
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
    
    var children: [DAFolder] {
        get {
            let folderSet = nsChildren as? Set<DAFolder> ?? []
            return folderSet.sorted(by: {$0.cdTitle ?? "" > $1.cdTitle ?? ""})
        }
        set {
            nsChildren = NSSet(array: newValue)
        }
    }
    var collections: [DACollection] {
        get {
            let collectionSet = nsCollections as? Set<DACollection> ?? []
            return collectionSet.sorted(by: {$0.title > $1.title})
        }
        set {
            nsCollections = NSSet(array: newValue)
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

