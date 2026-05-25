//
//  Category.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/22/22.
//

import Foundation
import CoreData

extension DACategory {
    static let unassignedTitle: String = "Unassigned"
    static var unassignedCategory: DACategory?
    
    convenience init(
        context: NSManagedObjectContext,
        color: DAColor,
        title: String = ""
    ) {
        self.init(context: context)
        self.color = color
        self.title = title
        self.id = UUID()
        createTime = .now
        updateTime = .now
        unassigned = {
            let collection = DACollection(context: context)
            collection.id = UUID()
            collection.title = "Default"
            collection.unassignedForCategory = self
            collection.createTime = .now
            collection.updateTime = .now
            return collection
        }()
    }
    
    enum DAColor: String, CaseIterable, Identifiable, Hashable {
        case unassigned = "Category: Grey (Unassigned)"
        case blue = "Category: Blue"
        case green = "Category: Green"
        case orange = "Category: Orange"
        case pink = "Category: Pink"
        case purple = "Category: Purple"
        case yellow = "Category: Yellow"
        
        var id: String {
            return self.rawValue
        }
        
        var displayTitle: String {
            switch self {
            case .blue:
                return "Blue"
            case .green:
                return "Green"
            case .orange:
                return "Orange"
            case .pink:
                return "Pink"
            case .purple:
                return "Purple"
            case .yellow:
                return "Yellow"
            default:
                return "Unassigned"
            }
        }
    }
    
    var color: DAColor {
        get {
            DAColor(rawValue: rawColor ?? "") ?? .unassigned
        }
        set {
            rawColor = newValue.rawValue
        }
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
    
    var items: [DAItem] {
        get {
            let itemSet = nsItems as? Set<DAItem> ?? []
            return itemSet.sorted(by: {$0.title > $1.title})
        }
        set {
            nsItems = NSSet(array: newValue)
        }
    }
    var tags: [DATag] {
        get {
            let tagSet = nsTags as? Set<DATag> ?? []
            return tagSet.sorted(by: {$0.title > $1.title})
        }
        set {
            nsTags = NSSet(array: newValue)
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
    var folders: [DAFolder] {
        get {
            let folderSet = nsFolders as? Set<DAFolder> ?? []
            return folderSet.sorted(by: {$0.cdTitle ?? "" > $1.cdTitle ?? ""})
        }
        set {
            nsFolders = NSSet(array: newValue)
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


