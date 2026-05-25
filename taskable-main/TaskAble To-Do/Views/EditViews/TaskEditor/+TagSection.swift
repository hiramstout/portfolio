//
//  +TagSection.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/8/22.
//

import SwiftUI

extension TaskEditor {
    struct TagSection: View {
        @EnvironmentObject private var task: DATask
        
        @Environment(\.presentingField) private var presentingField
        @Environment(\.rootContext) private var rootContext
        @Environment(\.managedObjectContext) private var moc
        
        @StateObject var childConfig = ChildContextConfig<DATag>()
        
        var body: some View {
            ForEach($task.tags, id: \.id) { $tag in
                HStack {
                    Text(tag.displayTitle)
                        .background {
                            NavigationLink("") {
                                TagEditor(tagConfig: childConfig)
                                    .task {
                                        childConfig.updateObject(to: tag)
                                    }
                                    .environment(\.managedObjectContext, childConfig.childContext)
                            }
                            .opacity(0)
                        }
                    Spacer()
                    Button {
                        task.tags.removeAll {$0.id == tag.id}
                    } label: {
                        Image(systemName: "multiply.square.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
                .tag(tag.id)
            }
            .onAppear {
                childConfig.updateObject(to: nil, newContextWithParent: rootContext)
            }
            
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
                    TagSheet()
                        .environment(\.presentingField, presentingField)
                        .environmentObject(task)
                }
                .opacity(0)
            }
            .listRowBackground(Rectangle().foregroundColor(.gray))
        
            
            
        }
    }
}
