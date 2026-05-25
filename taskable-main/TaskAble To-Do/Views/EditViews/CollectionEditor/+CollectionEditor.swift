//
//  +Editor.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/30/22.
//

import SwiftUI
import CoreData

struct CollectionEditor: View {
    @ObservedObject var collectionConfig: ChildContextConfig<DACollection>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Title", text: $collectionConfig.object.title, prompt: Text("Title"))
                        .textFieldClearable(text: $collectionConfig.object.title)
                    CategoryPickerChip(categorical: collectionConfig.object)
                        .environment(\.managedObjectContext, collectionConfig.childContext)
                    Picker(selection: $collectionConfig.object.folder) {
                        Text("None")
                            .listRowSeparator(.visible)
                            .tag(Optional<DAFolder>.none)
                        ForEach(collectionConfig.object.category?.folders ?? [], id: \.id) { folder in
                            Text(folder.title)
                                .tag(Optional<DAFolder>(folder))
                        }
                    } label: {
                        Text("Folder")
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(collectionConfig.newObject ? "Create" : "Update") {
                    try! collectionConfig.childContext.save()
                    try! collectionConfig.childContext.parent?.save()
                    dismiss()
                }
            }
        }
    }
}


//struct CollectionListEditor_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//    @State static var collectionConfig = ChildContextConfig<DACollection>(usingParent: dataController.container.viewContext, category: PreviewData.Categories.home.category)
//
//    static var previews: some View {
//        CollectionList.CollectionEditor(collectionConfig: $collectionConfig)
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//            .preferredColorScheme(.dark)
//    }
//}
