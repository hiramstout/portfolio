//
//  +Tags.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/25/22.
//

import SwiftUI
extension ManageTab {
    struct Tags: View {
        @SectionedFetchRequest(
            sectionIdentifier: \.category,
            sortDescriptors: [SortDescriptor(\DATag.cdTitle, order: .forward)]
        ) private var tags: SectionedFetchResults<DACategory?, DATag>
        @Environment(\.managedObjectContext) private var moc
        
        var body: some View {
            VStack {
                List {
                    ForEach(tags) { section in
                        Section(section.id?.title ?? "") {
                            ForEach(section) { tag in
                                NavigationLink(tag.displayTitle, value: NavRoute.tagItemList(tag))
                            }
                        }
                    }
                }
            }
        }
    }
}
