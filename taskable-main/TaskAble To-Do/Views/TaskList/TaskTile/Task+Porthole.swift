
//  Task+Peekable.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/23/22.


import Foundation
import UIKit
import SwiftUI
import CoreData



extension DATask {
    
    var portholes: [Porthole] {
        
        var portholes: [Porthole] = []
        
//        if let folder = collection?.folder {
//            portholes.append(.folder(folder))
//        }
        if let collection {
            portholes.append(.collection(collection))
        }
        if let dueDate {
            portholes.append(.dueDate(dueDate))
        }
        if let deferDate {
            portholes.append(.deferDate(deferDate))
        }
        if let priority {
            portholes.append(.priority(priority))
        }
        if let duration {
            portholes.append(.duration(duration))
        }
        for reminder in reminders {
            portholes.append(.reminder(reminder))
        }
        
        for tag in tags {
            portholes.append(.tag(tag))
        }
        
        
        return portholes
    }
    
        
    enum Porthole: Hashable, Equatable {
        case dueDate(DueDate)
        case deferDate(Date)
        case priority(DATask.Priority)
        case tag(DATag)
        case folder(DAFolder)
        case collection(DACollection)
        case duration(TimeInterval)
        case reminder(Date)
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .deferDate(let deferDate):
                hasher.combine(1)
                hasher.combine(deferDate.timeIntervalSince1970)
            case .dueDate(let dueDate):
                hasher.combine(2)
                hasher.combine(dueDate.rawValue)
            case .priority(let priority):
                hasher.combine(3)
                hasher.combine(priority.rawValue)
            case .tag(let tag):
                hasher.combine(4)
                hasher.combine(tag)
            case .folder(let folder):
                hasher.combine(5)
                hasher.combine(folder)
            case .collection(let collection):
                hasher.combine(6)
                hasher.combine(collection)
            case .duration(let duration):
                hasher.combine(7)
                hasher.combine(duration)
            case .reminder(let reminder):
                hasher.combine(8)
                hasher.combine(reminder)
            }
        }
        
        var id: Self {
            return self
        }
        static var provider: String = ""
        
        var symbol: some View {
            struct Mod: ViewModifier {
                let porthole: Porthole
                func body(content: Content) -> some View {
                    switch porthole {
                    case .tag:
                        content
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(Color(uiColor: .systemBackground))
                            .font(.system(size: 17))
                    default:
                        content
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(Color(uiColor: .systemBackground))
                    }
                }
            }
            switch self {
            case .dueDate:
                return Image(systemName: "calendar")
                    .modifier(Mod(porthole: self))
            case .deferDate:
                return Image(systemName: "calendar.badge.clock")
                    .modifier(Mod(porthole: self))
            case .priority:
                return Image(systemName: "exclamationmark.circle.fill")
                    .modifier(Mod(porthole: self))
            case .tag:
                return Image(systemName: "tag.fill")
                    .modifier(Mod(porthole: self))
            case .folder:
                return Image(systemName: "folder.fill")
                    .modifier(Mod(porthole: self))
            case .collection:
                return Image(systemName: "circle.grid.2x2.fill")
                    .modifier(Mod(porthole: self))
            case .duration:
                return Image(systemName: "clock.fill")
                    .modifier(Mod(porthole: self))
            case .reminder:
                return Image(systemName: "alarm.fill")
                    .modifier(Mod(porthole: self))
            }
        }
        
        var symbolPadding: EdgeInsets {
            switch self {
            case .dueDate, .deferDate, .collection:
                return EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 2)
            case .tag:
                return EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 3)
            case .reminder:
                return EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 1)
            case .priority:
                fallthrough
            default:
                return EdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 2)
            }
        }
        
        var color: Color {
            switch self {
            case .dueDate:
                return Color("Label: Red (Due Date)")
            case .deferDate:
                return .gray
            case .tag:
                return Color("Label: Purple (Tag)")
            case .priority:
                return .yellow
            case .folder:
                return .brown
            case .collection:
                return Color("Label: Grey (Collection)")
            case .duration:
                return .cyan
            case .reminder:
                return .teal
            }
        }
        
        var label: some View {
            struct LabelViewModifier: ViewModifier {
                @Environment(\.colorScheme) private var colorScheme
                
                let porthole: Porthole
                var font: Font {
                    switch porthole {
                    case .priority:
                        return .system(size: 20, weight: .heavy)
                    default:
                        return .system(size: 14, weight: .medium)
                    }
                }
                
                
                func body(content: Content) -> some View {
                    content
                        .foregroundColor( (colorScheme == .light) ?
                            .white : .black)
                        .font(font)
                }
            }
            switch self {
            case .dueDate(let dueDate):
                switch dueDate {
                case .strict(let date):
                    return AnyView(
                        Text(Date.now.distance(to: date).summary)
                            .modifier(LabelViewModifier(porthole: self))
                    )
                case .flexible:
                    return AnyView(EmptyView())
                }
            case .deferDate(let date):
                return AnyView(
                    Text(Date.now.distance(to: date).summary)
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .tag(let tag):
                return AnyView(
                    Text(tag.displayTitle)
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .priority(let priority):
                return AnyView(
                    Image(systemName: "ellipsis", variableValue: priority.rawValue)
                        .symbolRenderingMode(.hierarchical)
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .folder(let folder):
                return AnyView(
                    Text(folder.title)
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .collection(let collection):
                return AnyView(
                    Text(collection.title)
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .duration(let duration):
                return AnyView(
                    Text("\(Int(duration / (60*60)))h \(Int(duration / 60))m")
                        .modifier(LabelViewModifier(porthole: self))
                )
            case .reminder(let reminder):
                return AnyView(
                    Text(Date.now.distance(to: reminder).summary)
                        .modifier(LabelViewModifier(porthole: self))
                )
            }
            
        }
    }
    
}
