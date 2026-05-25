//
//  +Categories.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/23/22.
//

import SwiftUI

extension ManageTab {
    struct Categories: View {
        @FetchRequest(
            sortDescriptors: [SortDescriptor(\DACategory.cdTitle, order: .forward)],
            predicate: NSPredicate(format: "self != %@", DACategory.unassignedCategory!)
        ) private var categories: FetchedResults<DACategory>
        @Environment(\.managedObjectContext) private var moc
        
        var body: some View {
            VStack {
                List {
                    ForEach(categories, id: \.id) { category in
                        NavigationLink(category.title, value: NavRoute.categoryItemList(category))
                    }
                }
            }
        }
    }
}
