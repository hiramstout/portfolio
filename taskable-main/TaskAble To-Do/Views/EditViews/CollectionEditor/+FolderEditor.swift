//
//  +FolderEditor.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/1/22.
//

import SwiftUI
import CoreData

struct FolderEditor: View {
    @ObservedObject var folderConfig: ChildContextConfig<DAFolder>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $folderConfig.object.title, prompt: Text("Title"))
                        .textFieldClearable(text: $folderConfig.object.title)
                    CategoryPickerChip(categorical: folderConfig.object)
                        .environment(\.managedObjectContext, folderConfig.childContext)
                    
                    Picker(selection: $folderConfig.object.parent) {
                        Text("None")
                            .listRowSeparator(.visible)
                            .tag(Optional<DAFolder>.none)
                        ForEach(folderConfig.object.category?.folders ?? [], id: \.id) { folder in
                            Text(folder.title)
                                .tag(Optional<DAFolder>(folder))
                        }
                    } label: {
                        Text("Parent")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(folderConfig.newObject ? "Create" : "Update") {
                    try! folderConfig.childContext.save()
                    try! folderConfig.childContext.parent?.save()
                    
                    dismiss()
                }
            }
        }
    }
}

