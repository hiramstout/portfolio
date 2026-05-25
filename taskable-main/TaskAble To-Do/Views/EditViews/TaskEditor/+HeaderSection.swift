//
//  +HeaderSection.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/8/22.
//

import SwiftUI
import CoreData

extension TaskEditor {
    struct HeaderSection: View {
        @EnvironmentObject private var task: DATask
        
        var body: some View {
            CategoryPickerChip(categorical: task)
            
            Picker(selection: $task.collection) {
                if let unassigned = task.category?.unassigned {
                    Text(unassigned.title)
                        .tag(Optional<DACollection>(unassigned))
                }
                ForEach(task.category?.collections ?? [], id: \.id) { collection in
                    Text(collection.title)
                        .tag(Optional<DACollection>(collection))
                }
            } label: {
                Image(systemName: "circle.grid.2x2.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.secondary)
                HStack {
                    Text("Collection")
                }
            }
            .pickerStyle(.navigationLink)

            PriorityChip()
        }
    }
}
