//
//  ViewMenu.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/24/22.
//

import SwiftUI


struct VisibilityMenu: ToolbarContent {
    @Environment(\.itemFilters) var filters
    @Environment(\.sortOptions) var sortOptions
    
    private let hideCompleted: TaskList.Filters = .statusIsNot(.completed)
    private var hidingCompleted: Bool {
        filters?.contains {$0.wrappedValue == hideCompleted}
        ?? true
    }
    @State private var presentingSortSheet = false
    @State private var editMode: EditMode = .active
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    if hidingCompleted {
                        filters?.wrappedValue.removeAll(where: {$0 == hideCompleted})
                    } else {
                        filters?.wrappedValue.append(hideCompleted)
                    }
                } label: {
                    if hidingCompleted {
                        Label("Show Completed", systemImage: "checkmark")
                            .labelStyle(.titleOnly)
                    } else {
                        Label("Show Completed", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                    }
                }
                Button("Sort") {
                    presentingSortSheet.toggle()
                }
            } label: {
                Label("Visibility", systemImage: "eye.fill")
                    .foregroundColor(.secondary)
            }
            .menuStyle(.button)
            .sheet(isPresented: $presentingSortSheet) {
            } content: {
                NavigationStack {
                    List(sortOptions?.options ?? .constant([]), id: \.id, editActions: .move) { $option in
                        Button {
                            option.direction = (option.direction == .ascending) ? .descending : .ascending
                        } label: {
                            Label(
                                option.field.title,
                                systemImage: "arrow.\(option.direction == .ascending ? "up" : "down")"
                            )
                        }
                        .tag(option.id)
                    }
                    .environment(\.editMode, $editMode)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                presentingSortSheet.toggle()
                            } label: {
                                Text("Done")
                            }
                            
                        }
                    }
                    .navigationTitle("Sort Order")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

