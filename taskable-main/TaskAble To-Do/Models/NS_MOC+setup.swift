//
//  CoreData+DefaultIDs.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/18/22.
//

import Foundation
import CoreData


// MARK: - NSManagedObjectContext Global Extension
//
extension NSManagedObjectContext {
    static var projContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    func setup() throws {
        Self.projContext = self
        let request = DACategory.fetchRequest()
        request.predicate = NSPredicate(format: "cdTitle == %@", DACategory.unassignedTitle)
        let results = try self.fetch(request)
        
        
        if !results.isEmpty {
            DACategory.unassignedCategory = results[0]
            DACollection.unassigned = results[0].unassigned!
        } else {
            let category = DACategory(
                context: self,
                color: .unassigned,
                title: DACategory.unassignedTitle)
            DACategory.unassignedCategory = category
            DACollection.unassigned = category.unassigned!
            try self.save()
            
            PreviewData.setup(with: self)
            try self.save()
        }
    }
    
    var isRootContext: Bool {
        persistentStoreCoordinator != nil
        && parent == nil
    }
}
