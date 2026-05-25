//
//  CollectionEditor.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/25/22.
//

import SwiftUI



struct CollectionList: View {
    @FetchRequest(
        sortDescriptors: []
    ) private var categories: FetchedResults<DACategory>
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                ListChip(container: category)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        
        
    }
}

//struct CollectionEditor_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//    
//    static var previews: some View {
//        CollectionList()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//            .environment(\.rootContext, dataController.container.viewContext)
//    }
//}
