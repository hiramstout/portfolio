//
//  CategoryPickerChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/30/22.
//

import SwiftUI
import CoreData

protocol Categorical: NSManagedObject {
    var category: DACategory? { get set }
}
extension DATask: Categorical {
    
}
extension DACollection: Categorical {}
extension DAFolder: Categorical {}
extension DATag: Categorical {}

struct CategoryPickerChip<T: Categorical>: View {
    @FetchRequest(
        sortDescriptors: []
    ) private var categories: FetchedResults<DACategory>
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.rootContext) private var rootContext
    
    var category: DACategory {
        categorical.category ?? DACategory.unassignedCategory!
    }
    
    var categorical: T
    
    var body: some View {
        HStack {
            Image(systemName: "rectangle.fill.on.rectangle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.secondary)
                .font(.system(size: 20.5))
            Text("Category")
            Spacer()
            Menu {
                Section {
                    ForEach(categories) { category in
                        switch category.id {
                        case DACategory.unassignedCategory!.id:
                            EmptyView()
                                .tag(category.id)
                                
                        default:
                            Button(category.title) {
                                categorical.category = category
                                switch categorical {
                                case let task as DATask:
                                    task.collection = category.unassigned
                                default:
                                    break
                                }
                            }
                            .tag(category.id)
                        }
                    }
                }
                Section {
                    NavigationLink {
                        CategoryEditor()
                            .environment(\.managedObjectContext, rootContext)
                    } label: {
                        Label("Customize", systemImage: "list.bullet.rectangle")
                    }
                }
            } label: {
                Spacer()
                Text(category.title)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .scaledToFit()
                    .padding(.all, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(
                                Color(category.color.rawValue)  )
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.regularMaterial, lineWidth: 3)
                    }
                    .foregroundColor(Color(uiColor: .darkGray))
                    .animation(.default, value: category)
            }
            .menuStyle(.button)
            .onAppear {
                moc.automaticallyMergesChangesFromParent = true
            }
        }
    }
}

