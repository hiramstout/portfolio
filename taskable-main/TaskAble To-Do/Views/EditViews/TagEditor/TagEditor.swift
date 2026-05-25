//
//  NewTagView.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/4/22.
//

import SwiftUI
import CoreData

struct TagEditor: View {
    typealias OptDATag = Optional<DATag>
    
    @ObservedObject var tagConfig: ChildContextConfig<DATag>
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.rootContext) private var rootContext
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        sortDescriptors: []
    ) private var tags: FetchedResults<DATag>
    
    @State private var presentingTypePicker = false
    @State private var presentingDeleteConfirmation = false
    
    // New tag produces Context in environment is not connected to a persistent store coordinator
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("Title", text: $tagConfig.object.title)
                        
                        CategoryPickerChip(categorical: tagConfig.object)
                        
                        Button {
                            presentingTypePicker.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundStyle(Color("Label: Purple (Tag)"))
                                    .symbolRenderingMode(.monochrome)
                                    .font(.system(size: 20.5))
                                Text("Tag Type")
                                    .foregroundColor(colorScheme == .light ? .black : .white)
                                Spacer()
                                Text(tagConfig.object.type.rawValue)
                            }
                        }
                        .expandableRowContent(
                            height: presentingTypePicker ? 45 : 0
                        ) {
                            Picker("Type", selection: $tagConfig.object.type) {
                                ForEach(DATag.TagType.allCases) { tagType in
                                    Text(tagType.rawValue)
                                        .tag(tagType)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                            Divider()
                                .foregroundStyle(.secondary)
                                .padding(.trailing, -13)
                                .padding(.leading, 42)
                        }
                        .listRowSeparator(.hidden)
                        
                        
                        Picker(selection: $tagConfig.object.parent) {
                            Section {
                                Text("None")
                                    .tag(OptDATag.none)
                            }
                            Section {
                                ForEach(tags) { (tagIteration: DATag) in
                                    Text(tagIteration.displayTitle)
                                        .tag(OptDATag(tagIteration))
                                }
                            }
                            
                        } label: {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .symbolRenderingMode(.monochrome)
                                    .font(.system(size: 20.5))
                                Text("Parent")
                            }
                        }
                        .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                            Divider()
                                .foregroundStyle(.secondary)
                                .padding(.top, -4)
                                .padding(.trailing, -20)
                                .padding(.leading, 35)
                        }
                    }
                }
            }
        }
        .onChange(of: moc) { _ in
            tags.nsPredicate = NSPredicate(
                format: "(self != %@) AND NOT (self IN %@)",
                tagConfig.object,
                tagConfig.object.descendants)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(tagConfig.newObject ? "Create" : "Confirm") {
                    try! moc.save()
                    try! rootContext.save()
                    dismiss()
                }
                .disabled(tagConfig.object.title == "")
            }
            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) {
                    presentingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                        .labelStyle(.titleAndIcon)
                }
                .confirmationDialog("Are you sure you want to delete this tag?", isPresented: $presentingDeleteConfirmation) {
                    Button("Delete tag", role: .destructive) {
                        if tagConfig.newObject {
                            moc.rollback()
                            dismiss()
                        } else {
                            moc.delete(tagConfig.object)
                            try! moc.save()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct TagEditor_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    static var tagConfig = {
        let request: NSFetchRequest<DATag> = DATag.fetchRequest()
        request.predicate = NSPredicate(format: "cdTitle CONTAINS[cd] %@", "Laptop")
        let result = try! dataController.container.viewContext.fetch(request)
        if !result.isEmpty {
            let tag = result[0]
            let tagConfig = ChildContextConfig(usingParent: dataController.container.viewContext, with: tag)
            return tagConfig
        } else {
            fatalError()
        }
        
    }()
    
    static var previews: some View {
        TagEditor(tagConfig: tagConfig)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environment(\.rootContext, dataController.container.viewContext)
    }
}
