//
//  +SortDescriptors.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/23/22.
//

import SwiftUI
import CoreData

extension TaskList {
    enum Filters: Equatable {
        case inCategory(DACategory)
        case notInCategory(DACategory)
        case statusIs(DATask.Status)
        case statusIsNot(DATask.Status)
        case hasTag(DATag)
        case inCollection(DACollection)
        
        
        var filter: NSPredicate {
            switch self {
            case .inCategory(let category):
                return NSPredicate(format: "(category == %@)",category)
            case .notInCategory(let category):
                return NSPredicate(format: "(category != %@)",category)
            case .statusIs(let status):
                return NSPredicate(format: "(rawStatus == %@)", status.rawValue)
            case .statusIsNot(let status):
                return NSPredicate(format: "(rawStatus != %@ or rawStatus == nil)", status.rawValue)
            case .hasTag(let tag):
                return NSPredicate(format: "(ANY nsTags == %@)", tag)
            case .inCollection(let collection):
                return NSPredicate(format: "(collection == %@)",collection)
            }
        }
    }
    
    struct SortOptions: Equatable {
        static func ==(lhs: Self, rhs: Self) -> Bool {
            if lhs.options.endIndex != rhs.options.endIndex {
                return false
            }
            for (index, option) in lhs.options.enumerated() {
                if rhs.options[index] != option {
                    return false
                }
            }
            return true
        }
        static func !=(lhs: Self, rhs: Self) -> Bool {
            return !(lhs == rhs)
        }
        struct Option: Identifiable, Equatable {
            var field: SortField
            var direction: SortDirection
            var id: SortField.ID {
                field.id
            }
            var descriptor: SortDescriptor<DAItem> {
                field.descriptor(direction)
            }
        }
        
        var options: [Option] = {
            var options: [Option] = []
            for field in SortField.allCases {
                options.append(Option(field: field, direction: .ascending))
            }
            return options
        }()
        
        var rawValue: [SortDescriptor<DAItem>] {
            var descriptors: [SortDescriptor<DAItem>] = []
            for option in options {
                descriptors.append(option.descriptor)
            }
            return descriptors
        }
        var nsDescriptors: [NSSortDescriptor] {
            var descriptors: [NSSortDescriptor] = []
            for option in options {
                descriptors.append(option.field.nsDescriptor(option.direction))
            }
            return descriptors
        }
        
    }
    enum SortField: Identifiable, CaseIterable, Equatable {
        
        case byCreateTime
        case byCategory
        case byStatus
        case byTitle
        
        func descriptor(_ direction: SortDirection) -> SortDescriptor<DAItem> {
            switch self {
            case .byCreateTime:
                return SortDescriptor(\.createTime, order: direction.rawValue)
            case .byCategory:
                return SortDescriptor(\.category?.title, order: direction.rawValue)
            case .byStatus:
                return SortDescriptor(\.rawStatus, order: direction.rawValue)
            case .byTitle:
                return SortDescriptor(\.title, order: direction.rawValue)
            }
        }
        func nsDescriptor(_ direction: SortDirection) -> NSSortDescriptor {
            switch self {
            case .byCreateTime:
                return NSSortDescriptor(SortDescriptor(\DAItem.cdCreateTime, order: direction.rawValue))
            case .byCategory:
                return NSSortDescriptor(SortDescriptor(\DAItem.category?.cdTitle, order: direction.rawValue))
            case .byStatus:
                return NSSortDescriptor(SortDescriptor(\DAItem.rawStatus, order: direction.rawValue))
            case .byTitle:
                return NSSortDescriptor(SortDescriptor(\DAItem.cdTitle, order: direction.rawValue))
            }
        }
        
        init(with option: Self) {
            self = option
        }
        
        var id: Int {
            switch self {
            case .byCreateTime:
                return 1
            case .byCategory:
                return 2
            case .byStatus:
                return 3
            case .byTitle:
                return 4
            }
        }
        
        var title: String {
            switch self {
            case .byCreateTime:
                return "Create Time"
            case .byCategory:
                return "Category"
            case .byStatus:
                return "Status"
            case .byTitle:
                return "Title"
            }
        }
    }
    enum SortDirection: RawRepresentable {
        case ascending, descending
        
        var rawValue: SortOrder {
            switch self {
            case .ascending:
                return .forward
            case .descending:
                return .reverse
            }
        }
        init(rawValue: SortOrder) {
            switch rawValue {
            case .forward:
                self = .ascending
            case .reverse:
                self = .descending
            }
        }
    }
}
