//
//  PreviewTask.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/23/22.
//

import Foundation
import CoreData

struct PreviewData {
    static var tasks: [DATask] {
        var tasks: [DATask] = []
        for task in Tasks.allCases {
            tasks.append(task.task)
        }
        return tasks
    }
    
    enum Tasks: CaseIterable {
    case randy, five9, qa, calls, family
        
        var task: DATask {
            switch self {
            case .randy:
                return Tasks.randyTask
            case .five9:
                return Tasks.five9Task
            case .qa:
                return Tasks.qaTask
            case .calls:
                return Tasks.callsTask
            case .family:
                return Tasks.visitFamily
            }
            
        }
        
        private static var randyTask = {
            let task = DATask(
                context: NSManagedObjectContext.projContext,
                title: "")
            task.cdID = UUID()
            
            task.title = "Input Randy's unavailable time"
            task.notes = "Randy sent me his unavailable time in Slack, I just need to make sure to put in into the attendance tracker"
            task.dueDate = DATask.DueDate.strict(Date(timeIntervalSinceNow: 6000))
            task.deferDate = nil
            task.reminders = [
                Date(timeIntervalSinceNow: 3000)
            ]
            task.collection = Categories.work.category.unassigned!
            task.priority = DATask.Priority.medium
            task.category = Categories.work.category
            task.tags = [Tag.laptop.tag]
            task.duration = 1800
            task.status =  DATask.Status.designated
            task.createTime = .now
            
            try! NSManagedObjectContext.projContext.save()
            return task
        }()
        private static var five9Task = {
            let task = DATask(
                context: NSManagedObjectContext.projContext,
                title: "")

            task.title =  "Post Five9 Confluence article"
            task.notes =  "Cross post Five9 attendance expectations to the public Confluence space"
            task.dueDate = DATask.DueDate.strict(Date(timeIntervalSinceNow: 600000))
            task.deferDate =  Date(timeIntervalSinceNow: 60000)
            task.collection = Categories.work.category.unassigned!
            task.reminders =  [
                Date(timeIntervalSinceNow: 30000)
            ]
            task.priority = DATask.Priority.high
            task.category =  Categories.work.category
            task.tags =  [Tag.laptop.tag]
            task.duration =  600
            task.status = DATask.Status.designated
            task.createTime = .now
            
            try? NSManagedObjectContext.projContext.save()
            return task
        }()
        private static var qaTask = {
            let task = DATask(
                context: NSManagedObjectContext.projContext,
                title: "")

            task.title =  "Finish QA scorecards"
            task.dueDate = DATask.DueDate.strict(Date(timeIntervalSinceNow: 600000))
            task.priority =  DATask.Priority.low
            task.collection = Categories.work.category.unassigned!
            task.category =  Categories.work.category
            task.tags =  [Tag.laptop.tag]
            task.duration =  18000
            task.status = DATask.Status.designated
            task.createTime = .now
            
            try? NSManagedObjectContext.projContext.save()
            return task
        }()
        private static var callsTask = {
            let task = DATask(
                context: NSManagedObjectContext.projContext,
                title: "")

            task.title =  "Wrap up my calls"
            task.collection = Categories.work.category.unassigned
            task.category =  Categories.work.category
            task.status = DATask.Status.designated
            task.createTime = .now
            
            try? NSManagedObjectContext.projContext.save()
            return task
        }()
        private static var visitFamily = {
            let task = DATask(
                context: NSManagedObjectContext.projContext,
                title: "")

            task.title =  "Visit my family"
            task.category =  Categories.home.category
            task.collection = Categories.home.category.unassigned
            task.tags =  [Tag.parentsHouse.tag]
            task.status = DATask.Status.designated
            task.createTime = .now
            
            try? NSManagedObjectContext.projContext.save()
            return task
        }()

    }
    
    static var categories: [DACategory] {
        var categories: [DACategory] = []
        for category in Categories.allCases {
            categories.append(category.category)
        }
        return categories
    }
    
    enum Categories: CaseIterable {
        case work
        case home
        case unassigned
        
        var category: DACategory {
            switch self {
            case .work:
                return Self.workCategory
            case .home:
                return Self.homeCategory
            default:
                return DACategory.unassignedCategory!
            }
        }
        
        private static var workCategory = {
            let category = DACategory(
                context: NSManagedObjectContext.projContext,
                color: .blue,
                title: "Work")
            
            try! NSManagedObjectContext.projContext.save()
            return category
        }()
        private static var homeCategory = {
            let category = DACategory(
                context: NSManagedObjectContext.projContext,
                color: .green,
                title: "Home")
            
            try! NSManagedObjectContext.projContext.save()
            return category
        }()
    }
    
    static var tags: [DATag] {
        var tags: [DATag] = []
        for tag in Tag.allCases {
            tags.append(tag.tag)
        }
        return tags
    }
    
    enum Tag: CaseIterable {
        case laptop
        case parentsHouse
        
        var tag: DATag {
            switch self {
            case .laptop:
                return Self.laptopTag
            case .parentsHouse:
                return Self.parentsHouseTag
            }
        }
        
        private static var laptopTag = {
            let tag = DATag(
                context: NSManagedObjectContext.projContext,
                title: "Laptop",
                category: .unassignedCategory)
            tag.type = DATag.TagType.resource
            tag.cdActive =  true

            try! NSManagedObjectContext.projContext.save()
            return tag
        }()
                
        private static var parentsHouseTag = {
            let tag = DATag(
                context: NSManagedObjectContext.projContext,
                title: "Parent's House",
                category: .unassignedCategory)
            tag.type =  DATag.TagType.person
            tag.cdActive =  true
            
            try! NSManagedObjectContext.projContext.save()
            return tag
        }()
    }
    
    static func setup(with context: NSManagedObjectContext) {
        
        for category in categories {
            _ = category
        }
        for tag in tags {
            _ = tag
        }
        for task in tasks {
            _ = task
        }
    }
    
    static func exportDataToCode(context: NSManagedObjectContext) -> String {
        return ""
    }
}

extension DATask {
    func structCodeString() -> String {
        
        return """
        let task = DATask(
            context: context,
            title: "")
        task.id = UUID(uuidString: \(id.uuidString))
        task.title = "\(title)"
        task.notes = "\(notes)"
        task.dueDate = \(dueDate?.codeString ?? "nil")
        task.deferDate = \(deferDate?.codeString ?? "nil")
        task.reminders = [
        \(reminders.map {"\t" + $0.codeString + "\n"})
        ]
        task.collection = UUID - \(collection?.id.uuidString ?? "nil")
        task.priority = \(priority?.rawValue.description ?? "nil")
        task.category = UUID - \(category?.id.uuidString ?? "nil")
        task.tags = [
            
        ]
        task.duration = \(duration?.description ?? "nil")
        task.status =  .\(status.rawValue)
        task.createTime = \(createTime.codeString)
        """
    }
}
