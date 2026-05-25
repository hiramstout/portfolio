//
//  TaskListView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/23/22.
//

import SwiftUI

struct InboxTab: View {
    @State private var filters: [TaskList.Filters] = [
        .inCategory(DACategory.unassignedCategory!),
        .statusIsNot(.completed)
    ]
    @State private var sortOptions = TaskList.SortOptions()
    
    var body: some View {
        NavigationStack {
            TaskList()
                .navigationTitle("Inbox")
                .toolbar {
                    VisibilityMenu()
                }
        }
        .environment(\.itemFilters, $filters)
        .environment(\.sortOptions, $sortOptions)
        
    }
}

struct Home_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    
    static var previews: some View {
        InboxTab()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
