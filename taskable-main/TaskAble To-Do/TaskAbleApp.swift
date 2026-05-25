//
//  QuestDirectorApp.swift
//  QuestDirector
//
//  Created by Hiram Stout on 10/13/22.
//

import SwiftUI
import CoreData
import UserNotifications

// Could also name app TaskAble
// TODO:
// - EventKit
// - UserNotifications
// - StoreKit
// - WidgetKit
// - CoreSpotlight
// - CloudKit
// - BackgroundTasks
// - ApplicationServices
// - WatchOS
// - WatchKit
// - Accessibility
// Focus modes?
//
//
// - Search box in Manage tab
// - Porthole windows for tags and reminders? With increased size
// 
// In task editor, clean up:
// - Reminders list
// - Tag list/editor
// - Add option for due date based reminders (day before, etc.)
// - Restrict child - parent relationship so both cannot be children
//   - Done for DATag
// - Archiving collections (in addition to deleting)
// - Allow unassigned category selection

@main
struct TaskAble: App {
    #if TEST
    @StateObject private var dataController = DataController(inMemory: true)
    #else
    @StateObject private var dataController = DataController()
    #endif
    
    @State var err: DAError? = nil
    @State var authorizedForUN: Bool = false
    
    var body: some Scene {
        WindowGroup {
            DATabView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(\.rootContext, dataController.container.viewContext)
                .environment(\.err, $err)
                .environment(\.unAuthorized, $authorizedForUN)
                .task {
                    await checkNotificationAccess()
                }
        }
        .onChange(of: authorizedForUN) { newValue in
            NSManagedObject.authorizedForUN = newValue
        }
    }
    enum WindowGroupType: String {
        case categories = "Categories"
    }
    func checkNotificationAccess() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .denied:
            authorizedForUN = false
        case .authorized:
            authorizedForUN = true
        case .notDetermined:
            var error: DAError? = nil
            var granted: Bool = false
            do {
                granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            } catch let e as NSError {
                error = .nsError(e)
            }
            if !granted {
                let settings = await center.notificationSettings()
                switch settings.authorizationStatus {
                case .denied:
                    authorizedForUN = false
                case .authorized:
                    authorizedForUN = true
                default:
                    authorizedForUN = false
                    err = error
                }
            } else {
                authorizedForUN = true
            }
        default:
            err = .unknownError("checking notification authorization status returned status code of: \(settings.authorizationStatus.rawValue)")
        }
        
    }
}

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        
        let container = NSPersistentContainer(name: "CoreData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        }
        
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.container = container
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave, object: container.viewContext, queue: .main, using: managedObjectContextObjectsDidChange(notification:))
        
        
        
        // Setup DACategory default category static vars
        do {
            try container.viewContext.setup()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func managedObjectContextObjectsDidChange(notification: Notification) {
        guard let moc = notification.object as? NSManagedObjectContext else {
            NSLog("""
                No NSManagedObjectContext object in will save notification. Info:
                - notification.description: \(notification.description)
                - notification.object: \(notification.object.debugDescription)
                
                """)
            return
        }
        
        for insert in moc.insertedObjects {
            switch insert {
            case let task as DATask:
                for reminder in task.reminders {
                    task.addReminderNotification(for: reminder)
                    NSLog("""
                        Added reminder for task:
                        - task.title: \(task.title)
                        - reminder: \(reminder.formatted())
                        """)
                }
            default:
                break
            }
        }

        for update in moc.updatedObjects {
            switch update {
            case let task as DATask:

                if let updatedReminders = task.changedValues()["cdReminders"] as? [Date],
                let currentReminders = task.committedValues(forKeys: ["cdReminders"])["cdReminders"] as? [Date] {
                    NSLog("""
                        Current reminders: \(currentReminders.debugDescription)
                        New Reminders: \(updatedReminders.debugDescription)
                        """)
                    let newReminders = updatedReminders.compactMap { currentReminders.contains($0) ? nil : $0 }
                    let removedReminders = currentReminders.compactMap { updatedReminders.contains($0) ? nil : $0 }
                    for reminder in newReminders {
                        task.addReminderNotification(for: reminder)
                        NSLog("""
                            Added reminder for task:
                            - task.title: \(task.title)
                            - reminder: \(reminder.formatted())
                            """)
                    }
                    for reminder in removedReminders {
                        task.removeReminderNotification(for: reminder)
                        NSLog("""
                            Deleted reminder for task:
                            - task.title: \(task.title)
                            - reminder: \(reminder.formatted())
                            """)
                    }
                }
            default:
                break
            }
        }
        
        for delete in moc.deletedObjects {
            switch delete {
            case let task as DATask:
                NSLog("Checking task delete")
                for reminder in task.reminders {
                    task.removeReminderNotification(for: reminder)
                    NSLog("""
                        Deleted reminder for task:
                        - task.title: \(task.title)
                        - reminder: \(reminder.formatted())
                        """)
                }
            default:
                break
            }
        }
    }
}

protocol CDManagedObject: NSManagedObject {
    associatedtype ObjectType: NSManagedObject
    static func fetchRequest() -> NSFetchRequest<ObjectType>
}

extension DATask: CDManagedObject {
    typealias ObjectType = DATask
}
extension DAHabit: CDManagedObject {
    typealias ObjectType = DAHabit
}
extension DAIdea: CDManagedObject {
    typealias ObjectType = DAIdea
}
extension DATag: CDManagedObject {
    typealias ObjectType = DATag
}
extension DACollection: CDManagedObject {
    typealias ObjectType = DACollection
}
extension DAFolder: CDManagedObject {
    typealias ObjectType = DAFolder
}

class ChildContextConfig<Object: CDManagedObject>: Equatable, Hashable, ObservableObject {
    static func == (lhs: ChildContextConfig<Object>, rhs: ChildContextConfig<Object>) -> Bool {
        lhs.object == rhs.object
        && lhs.childContext == rhs.childContext
        && lhs.newObject == rhs.newObject
    }
    
    @Published var object: Object.ObjectType
    @Published fileprivate(set) var childContext: NSManagedObjectContext
    @Published fileprivate(set) var newObject: Bool
    
    init(usingParent parentContext: NSManagedObjectContext? = nil) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        object = Object.ObjectType()
        newObject = true
        if let parentContext {
            childContext.parent = parentContext
            childContext.automaticallyMergesChangesFromParent = true
            switch object.self {
            case is DATask:
                let object = DATask(context: childContext, title: "")
                self.object = object as! Object.ObjectType
            case is DATag:
                let object = DATag(context: childContext, title: "")
                self.object = object as! Object.ObjectType
            default:
                break
            }
        }
    }
    
    convenience init(
        usingParent parentContext: NSManagedObjectContext,
        with object: Object
    ) {
        self.init(usingParent: parentContext)
        let predicate = NSPredicate(
            format: "self == %@",
            object)
        let request = Object.fetchRequest()
        request.predicate = predicate
        let result = try! childContext.fetch(request)
        self.object = result[0]
        newObject = false
    }
    
    func updateObject(
        to replacement: Object?,
        newContextWithParent parent: NSManagedObjectContext? = nil
    ) {
        if let parent {
            childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            childContext.parent = parent
            childContext.automaticallyMergesChangesFromParent = true
        }
        
        if let replacement, self.childContext.parent != nil {
            let predicate = NSPredicate(
                format: "self == %@",
                replacement)
            let request = Object.fetchRequest()
            request.predicate = predicate
            let result = try! childContext.fetch(request)
            self.object = result[0]
            self.newObject = false
        } else {
            object = Object.ObjectType(context: childContext)
            newObject = false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.object)
        hasher.combine(self.childContext)
        hasher.combine(self.newObject)
    }
}

extension ChildContextConfig where Object == DATask {
    
    func updateObject(
        usingParent parentContext: NSManagedObjectContext,
        usingFilters filters: [TaskList.Filters]
    ) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        childContext.automaticallyMergesChangesFromParent = true
        
        var withCollection: DACollection? = nil
        var withCategory: DACategory? = nil
        var withTags: [DATag] = []
        for filter in filters {
            switch filter {
            case .inCategory(let category):
                let predicate = NSPredicate(
                    format: "self == %@",
                    category)
                let request: NSFetchRequest<DACategory> = DACategory.fetchRequest()
                request.predicate = predicate
                let result = try! childContext.fetch(request)
                withCategory = result[0]
            case .inCollection(let collection):
                let predicate = NSPredicate(
                    format: "self == %@",
                    collection)
                let request: NSFetchRequest<DACollection> = DACollection.fetchRequest()
                request.predicate = predicate
                let result = try! childContext.fetch(request)
                withCollection = result[0]
                withCategory = result[0].category ?? result[0].unassignedForCategory
            case .hasTag(let tag):
                let predicate = NSPredicate(
                    format: "self == %@",
                    tag)
                let request: NSFetchRequest<DATag> = DATag.fetchRequest()
                request.predicate = predicate
                let result = try! childContext.fetch(request)
                withTags.append(result[0])
            default:
                continue
            }
        }
        object = DATask(
            context: childContext,
            category: withCategory,
            collection: withCollection,
            title: "")
        object.tags = withTags
        newObject = true
    }
    

}


extension ChildContextConfig where Object == DACollection {
    
    func updateObject(
        usingParent parentContext: NSManagedObjectContext,
        parentContainer: CollectableContainer
    ) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        childContext.automaticallyMergesChangesFromParent = true
        
        switch parentContainer {
        case let parentCategory as DACategory:
            let predicate = NSPredicate(
                format: "self == %@",
                parentCategory)
            let request: NSFetchRequest<DACategory> = DACategory.fetchRequest()
            request.predicate = predicate
            let result = try! childContext.fetch(request)
            object = DACollection(context: childContext, category: result[0])
        case let parentFolder as DAFolder:
            let predicate = NSPredicate(
                format: "self == %@",
                parentFolder)
            let request: NSFetchRequest<DAFolder> = DAFolder.fetchRequest()
            request.predicate = predicate
            let result = try! childContext.fetch(request)
            object = DACollection(
                context: childContext,
                category: result[0].category ?? DACategory.unassignedCategory!,
                folder: result[0])
        default:
            object = Object.ObjectType()
        }
        self.newObject = true
    }
}

extension ChildContextConfig where Object == DAFolder {
    
    func updateObject(
        usingParent parentContext: NSManagedObjectContext,
        parentContainer: CollectableContainer
    ) {
        childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        childContext.automaticallyMergesChangesFromParent = true
        
        switch parentContainer {
        case let parentCategory as DACategory:
            let predicate = NSPredicate(
                format: "self == %@",
                parentCategory)
            let request: NSFetchRequest<DACategory> = DACategory.fetchRequest()
            request.predicate = predicate
            let result = try! childContext.fetch(request)
            object = DAFolder(context: childContext, category: result[0])
        case let parentFolder as DAFolder:
            let predicate = NSPredicate(
                format: "self == %@",
                parentFolder)
            let request: NSFetchRequest<DAFolder> = DAFolder.fetchRequest()
            request.predicate = predicate
            let result = try! childContext.fetch(request)
            object = DAFolder(
                context: childContext,
                category: result[0].category ?? DACategory.unassignedCategory!,
                parent: result[0])
        default:
            object = Object.ObjectType()
        }
        newObject = true
    }
}
/*
 Change flexible due date to enum (today, tomorrow, this week, this month)
 Have "plan" tab review what to do with flexible tasks
 Set hours for categories (work hours for work, etc.)
 
 TODO: Task groups
 TODO: Adjust manage lists to follow design patterns for the app. For example, similar to the category editor.
 TODO: Adjust animations for presenting fields in task editor
 TODO: Fix formatting for task editor
 TODO: Add to new reminder Field - when due, when deferred, a week from now, tomorrow
 TODO: Update task editor to follow app design patterns
 TODO: Add error handling to the code
 
 */
