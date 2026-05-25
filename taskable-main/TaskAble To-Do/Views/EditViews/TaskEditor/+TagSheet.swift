//
//  +TagSheet.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/8/22.
//

import SwiftUI
import CoreData

extension TaskEditor {
    struct TagSheet: View {
        @EnvironmentObject private var task: DATask
        
        @Environment(\.dismiss) private var dismiss
        @Environment(\.managedObjectContext) private var moc
        @Environment(\.rootContext) private var rootContext
        
        @FetchRequest(
            sortDescriptors: []
        ) private var tags: FetchedResults<DATag>
        
        @State private var tagToAdd: DATag? = nil
        @State private var newTagConfig = ChildContextConfig<DATag>(usingParent: nil)
        
        private var remainingTags: [DATag] {
            var tags = self.tags.map {$0}
            tags.removeAll(where: {task.tags.map {$0.id}.contains($0.id)})
            return tags
        }
        
        var body: some View {
            NavigationView {
                VStack {
                    Form {
                        Section {
                            Picker(selection: $tagToAdd) {
                                ForEach(remainingTags) { tag in
                                    Text(tag.displayTitle).tag(Optional<DATag>(tag))
                                }
                            } label: {
                                EmptyView()
                            }
                            .pickerStyle(.inline)
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .background {
                                NavigationLink("") {
                                    TagEditor(tagConfig: newTagConfig)
                                        .onAppear {
                                            newTagConfig = ChildContextConfig(
                                                usingParent: rootContext)
                                        }
                                        .environment(\.managedObjectContext, newTagConfig.childContext)
                                        .onDisappear {
                                            moc.refreshAllObjects()
                                        }
                                }
                                .opacity(0)
                            }
                            .listRowBackground(Rectangle().foregroundColor(.gray))
                        }
                    }
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let tagToAdd {
                            task.tags.append(tagToAdd)
                        }
                        dismiss()
                    }
                    .disabled(tagToAdd == nil)
                }
            }
        }
    }
}
