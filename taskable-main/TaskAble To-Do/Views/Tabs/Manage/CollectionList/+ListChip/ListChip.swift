//
//  +FolderCollectionList.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/1/22.
//

import SwiftUI
import CoreData
import Combine

protocol CollectableContainer: NSManagedObject {
    var collections: [DACollection] {get set}
    var folders: [DAFolder] {get set}
    var title: String {get set}
    var unassigned: DACollection? {get set}
}

extension DACategory: CollectableContainer {}
extension DAFolder: CollectableContainer {
    var folders: [DAFolder] {
        get {
            children
        }
        set {
            children = newValue
        }
    }
}

extension CollectionList {
    struct ListChip<T: CollectableContainer>: View {
        @ObservedObject var container: T
        init(container: T) {
            self.container = container
        }
        
        @Environment(\.editMode) var editMode
        @Environment(\.managedObjectContext) var moc
        
        @State var presentingNewDialog = false
        @State var collectionChildConfig = ChildContextConfig<DACollection>(usingParent: nil)
        @State var folderChildConfig = ChildContextConfig<DAFolder>(usingParent: nil)
        
        var notUnassigned: Bool {
            if let category = container as? DACategory,
               category == DACategory.unassignedCategory {
                return false
            } else {
                return true
            }
        }
        
        var body: some View {
            Section((T.self == DACategory.self) ? container.title : "") {

                CollectionRow(collection: container.unassigned!, childConfig: $collectionChildConfig)
                    .tag(container.unassigned)
                
                ForEach(container.folders, id: \.self) { folder in
                    FolderRow(folder: folder, childConfig: $folderChildConfig)
                        .tag(folder)
                }
                
                ForEach(container.collections, id: \.self) { collection in
                    CollectionRow(collection: collection, childConfig: $collectionChildConfig)
                        .tag(collection)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        for item in container.collections[index].items {
                            item.collection = container.unassigned
                        }
                        moc.delete(container.collections[index])
                        try! moc.save()
                    }
                }
                
                if notUnassigned && editMode?.wrappedValue.isEditing == true {
                    Button {
                        presentingNewDialog.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(Color(uiColor: .label))
                            Spacer()
                        }
                    }
                    .listRowBackground(Color(uiColor: .systemFill))
                }
            }
            .confirmationDialog(
                "New Collection Type",
                isPresented: $presentingNewDialog
            ) {
                NavigationLink("New Collection", value: ManageTab.NavRoute.collectionEditor(collectionChildConfig))
                NavigationLink("New Folder", value: ManageTab.NavRoute.folderEditor(folderChildConfig))
            }
            .onChange(
                of: presentingNewDialog
            ) { isPresenting in
                
                if isPresenting {
                    collectionChildConfig.updateObject(usingParent: moc, parentContainer: container)
                    folderChildConfig.updateObject(usingParent: moc, parentContainer: container)
                }
            }
        }
    }
    
}
