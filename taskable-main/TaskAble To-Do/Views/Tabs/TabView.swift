//
//  ContentView.swift
//  QuestDirector
//
//  Created by Hiram Stout on 10/13/22.
//

import SwiftUI
import Combine

enum DATab: String {
    case plan
    case inbox
    case manage
    case learn
//    case projects
//    case explore
//    case review
   func label() -> some View {
        switch self {
        case .plan:
            return Label("Plan", systemImage: "calendar")
        case .inbox:
            return Label("Inbox", systemImage: "tray.and.arrow.down.fill")
        case .manage:
            return Label("Manage", systemImage: "briefcase")
        case .learn:
            return Label("Learn", systemImage: "books.vertical")
        }
    }
}
extension Binding {
    func onUpdate(_ closure: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            closure(newValue)
            wrappedValue = newValue
        })
    }
}

struct DATabView: View {
    @State var currentTab: DATab = .inbox
    @State var navRoute: [ManageTab.NavRoute] = []
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $currentTab.onUpdate(checkForRepeat)) {
            PlannerTab()
                .tabItem(DATab.plan.label)
                .tag(DATab.plan)
            InboxTab()
                .tabItem(DATab.inbox.label)
                .tag(DATab.inbox)
            ManageTab(navRoute: $navRoute)
                .tabItem(DATab.manage.label)
                .tag(DATab.manage)
            LearnTab()
                .tabItem(DATab.learn.label)
                .tag(DATab.learn)
            // find/organize
            // collaborate?
            //
            
        }
    }
    
    func checkForRepeat(newValue: DATab) {
        if currentTab == newValue
          && currentTab == .manage
          && !navRoute.isEmpty {
            
            navRoute.removeLast()
        }
    }
}

struct DATabView_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    
    static var previews: some View {
        DATabView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
