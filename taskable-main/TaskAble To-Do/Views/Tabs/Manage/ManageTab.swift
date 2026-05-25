//
//  ManageTab.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/22/22.
//

import SwiftUI

struct ManageTab: View {
    enum NavRoute: Hashable {
        case categories
        case tags
        case categoryItemList(DACategory)
        case tagItemList(DATag)
        case collections
        case folderEditor(ChildContextConfig<DAFolder>)
        case collectionEditor(ChildContextConfig<DACollection>)
        case folderList(DAFolder)
        case collectionItemList(DACollection)
    }
    
    @Binding var navRoute: [NavRoute]
    @State private var editMode: EditMode = .inactive
    @State private var filters: [TaskList.Filters] = [.statusIsNot(.completed)]
    @State private var sortOptions = TaskList.SortOptions()
    
    var body: some View {
        
        NavigationStack(path: $navRoute) {
            VStack {
                List {
                    NavigationLink(value: NavRoute.categories) {
                        Text("Categories")
                    }
                    
                    NavigationLink(value: NavRoute.tags) {
                        Text("Tags")
                    }
                    
                    NavigationLink(value: NavRoute.collections){
                        Text("Collections")
                    }
                }
            }
            .navigationTitle("Manage")
            .navigationDestination(for: NavRoute.self) { route in
                switch route {
                case .folderEditor(let folderConfig):
                    let context = folderConfig.childContext
                    FolderEditor(folderConfig: folderConfig)
                        .environment(\.managedObjectContext, context)
                case .collectionEditor(let collectionConfig):
                    CollectionEditor(collectionConfig: collectionConfig)
                        .environment(\.managedObjectContext, collectionConfig.childContext)
                case .folderList(let folder):
                    List {
                        CollectionList.ListChip<DAFolder>(container: folder)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                    .navigationTitle(folder.title)
                case .collectionItemList(let collection):
                    TaskList()
                        .onAppear {
                            
                            filters = [
                                .inCollection(collection),
                                .statusIsNot(.completed)
                            ]
                        }
                        .toolbar {
                            VisibilityMenu()
                        }
                        .navigationTitle(collection.title)
                case .tags:
                    Tags()
                        .navigationTitle("Tags")
                case .categories:
                    Categories()
                        .navigationTitle("Categories")
                case .collections:
                    CollectionList()
                        .navigationTitle("Collections")
                        .environment(\.navRoute, $navRoute)
                case .tagItemList(let tag):
                    TaskList()
                    .navigationTitle(tag.title)
                    .onAppear {
                        filters = [
                            .hasTag(tag),
                            .statusIsNot(.completed)
                        ]
                    }
                    .toolbar {
                        VisibilityMenu()
                    }
                case .categoryItemList(let category):
                    TaskList()
                    .navigationTitle(category.title)
                    .onAppear {
                        filters = [
                            .inCategory(category),
                            .statusIsNot(.completed)
                        ]
                    }
                    .toolbar {
                        VisibilityMenu()
                    }
                }
            }
        }
        .environment(\.editMode, $editMode)
        .environment(\.itemFilters, $filters)
        .environment(\.sortOptions, $sortOptions)
    }
}

//struct ManageTab_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//
//    static var previews: some View {
//        ManageTab()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//            .preferredColorScheme(.dark)
//    }
//}
