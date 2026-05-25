//
//  +navigationLink.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/3/22.
//

import Foundation
import SwiftUI

extension CollectionList.ListChip {
    struct CollectionRow: View {
        @ObservedObject var collection: DACollection
        
        @Binding var childConfig: ChildContextConfig<DACollection>
        
        @Environment(\.editMode) private var editMode
        @Environment(\.rootContext) private var rootContext
        @Environment(\.navRoute) private var navRoute
        
        var body: some View {
            ZStack {
                if let editMode, editMode.wrappedValue.isEditing
                    && collection.unassignedForCategory != nil {
                    HStack {
                        Image(systemName: "circle.grid.2x2.fill")
                        
                        Text(collection.title)
                        Spacer()
                    }
                } else if let editMode {
                    NavigationLink(
                        value: (editMode.wrappedValue.isEditing)
                        ? ManageTab.NavRoute.collectionEditor(childConfig)
                        : ManageTab.NavRoute.collectionItemList(collection)
                    ) {
                        HStack {
                            Image(systemName: "circle.grid.2x2.fill")
                            Text(collection.title)
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        if editMode.wrappedValue.isEditing {
                            childConfig = ChildContextConfig(
                                usingParent: rootContext,
                                with: collection)
                            if let navRoute {
                                navRoute.wrappedValue.append(.collectionEditor(childConfig))
                            }
                        } else {
                            navRoute?.wrappedValue.append(.collectionItemList(collection))
                        }
                    }
                }
            }
        }
    }
    
    struct FolderRow: View {
        @ObservedObject var folder: DAFolder
        
        @Binding var childConfig: ChildContextConfig<DAFolder>
        
        @Environment(\.editMode) private var editMode
        @Environment(\.rootContext) private var rootContext
        @Environment(\.navRoute) private var navRoute
        
        var body: some View {
            ZStack {
                NavigationLink(
                    value: (editMode?.wrappedValue.isEditing == true)
                        ? ManageTab.NavRoute.folderEditor(childConfig)
                        : ManageTab.NavRoute.folderList(folder)
                ) {
                    HStack {
                        Image(systemName: "folder.fill")
                        Text(folder.title)
                        Spacer()
                    }
                }
                .onTapGesture {
                    
                    if editMode?.wrappedValue == .active {
                        childConfig = ChildContextConfig(
                            usingParent: rootContext,
                            with: folder)
                        navRoute?.wrappedValue.append(.folderEditor(childConfig))
                    }
                    
                }
            }
        }
    }
}
