//
//  +ColorPickerChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/21/22.
//

import SwiftUI

extension CategoryEditor.EditTile {
    struct ColorPickerChip: View {
        typealias OptRawColor = Optional<String>
        
        
        @ObservedObject var category: DACategory
        @FetchRequest(
            sortDescriptors: []
        ) private var categories: FetchedResults<DACategory>
        
        var unusedColors: [DACategory.DAColor] {
            var unused: [DACategory.DAColor] = []
            unused.append(category.color)

            for color in DACategory.DAColor.allCases {
                let used = categories.contains(where: {$0.color == color})
                if !used {
                    unused.append(color)
                }
            }
            return unused
        }
        
        var body: some View {
            Picker(selection: $category.color) {
                ForEach(unusedColors) { color in
                    Text(color.displayTitle).tag(color)
                }
            } label: {
                Text("Color Scheme")
            }
            .onAppear {
                categories.nsPredicate = NSPredicate(format: "self != %@", DACategory.unassignedCategory!)
            }
            .menuIndicator(.hidden)
        }
    }
}
