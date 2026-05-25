//
//  DAProvider.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/30/22.
//

import SwiftUI
//
//class DAProvider: ObservableObject {
//    @Published fileprivate(set) var items: [Item]
//    @Published fileprivate(set) var tags: [DATag]
//    @Published fileprivate(set) var categories: [DACategory]
//    @Published fileprivate(set) var folders: [DAFolder]
//    @Published fileprivate(set) var collections: [DACollection]
//    // TODO: Subscript
//    
//    init() {
//        items = []
//        tags = PreviewData.tags
//        categories = PreviewData.categories
//        for task in PreviewData.tasks {
//            items.append(Item.task(task))
//        }
//    }
//    
//    subscript(itemID id: UUID) -> Item? {
//        get {
//            items.first(where: {$0.id == id})
//        }
//        set {
//            if let newValue {
//                let index = items.firstIndex(where: {$0.id == id})
//                if let index {
//                    items[index] = newValue
//                } else {
//                    items.append(newValue)
//                }
//            } else {
//                items.removeAll(where: {$0.id == id})
//            }
//        }
//    }
//    
//    subscript(tagID id: DATag.ID) -> DATag? {
//        get {
//            tags.first(where: {$0.id == id})
//        }
//        set {
//            if let newValue {
//                let index = tags.firstIndex(where: {$0.id == id})
//                if let index {
//                    tags[index] = newValue
//                } else {
//                    tags.append(newValue)
//                }
//            } else {
//                tags.removeAll(where: {$0.id == id})
//            }
//        }
//    }
//    
//    subscript(categoryID id: DACategory.ID) -> DACategory? {
//        get {
//            categories.first(where: {$0.id == id})
//        }
//        set {
//            if let newValue {
//                if let index = categories.firstIndex(where: {$0.id == id}) {
//                    categories[index] = newValue
//                } else {
//                    categories.append(newValue)
//                }
//            } else {
//                categories.removeAll(where: {$0.id == id})
//            }
//        }
//    }
//    
//    fileprivate func loadItems(items: [Item]) {
//        self.items = items
//    }
//}
//
//extension DAProvider {
//    fileprivate enum DataFile: String {
//        case items = "items.data"
//        case tags = "tags.data"
//        case categories = "categories.data"
//        case collections = "collections.data"
//        case folders = "folders.data"
//    }
//    
//    fileprivate func fileURL(for file: DataFile) throws -> URL {
//        try FileManager.default.url(
//            for: .documentDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: false
//        )
//        .appendingPathComponent(file.rawValue)
//    }
//    
//    func load() throws {
//        var url = try fileURL(for: .items)
//        var file = try FileHandle(forReadingFrom: url)
//        let items: [Item] = try JSONDecoder().decode(
//            [Item].self,
//            from: file.availableData
//        )
//        self.items = items
//        
//        url = try fileURL(for: .categories)
//        file = try FileHandle(forReadingFrom: url)
//        let categories = try JSONDecoder().decode(
//            [DACategory].self,
//            from: file.availableData
//        )
//        self.categories = categories
//        
//        url = try fileURL(for: .tags)
//        file = try FileHandle(forReadingFrom: url)
//        let tags = try JSONDecoder().decode(
//            [DATag].self,
//            from: file.availableData
//        )
//        self.tags = tags
//        
//        url = try fileURL(for: .folders)
//        file = try FileHandle(forReadingFrom: url)
//        let folders = try JSONDecoder().decode(
//            [DAFolder].self,
//            from: file.availableData
//        )
//        self.folders = folders
//        
//        url = try fileURL(for: .collections)
//        file = try FileHandle(forReadingFrom: url)
//        let collections = try JSONDecoder().decode(
//            [DACollection].self,
//            from: file.availableData
//        )
//        self.collections = collections
//    }
//    
//    func save() async throws {
//        
//    }
//    
//}
