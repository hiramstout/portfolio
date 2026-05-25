//
//  CategoryEditView.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/5/22.
//

import SwiftUI
import CoreData

struct CategoryEditor: View {
    private var moc = NSManagedObjectContext.projContext
    
    @FetchRequest(
        sortDescriptors: [
            .init(keyPath: \DACategory.cdCreateTime, ascending: true)
        ]
    ) private var categories: FetchedResults<DACategory>
    
    @State private var expanded: UUID? = nil
    private let max = 6
    
    private var unusedColors: [DACategory.DAColor] {
        var unused: [DACategory.DAColor] = []
        for color in DACategory.DAColor.allCases {
            let used = categories.contains(where: {$0.color == color})
            if !used && color != .unassigned {
                unused.append(color)
            }
        }
        return unused
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text("Total Used: \(categories.count)/\(max)")
                            .font(.title2)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    ForEach(categories.sorted {$0.title > $1.title}, id: \.id) { category in
                        switch category.id {
                        case DACategory.unassignedCategory?.id:
                            EmptyView()
                        case expanded:
                            EditTile(
                                expanded: $expanded,
                                category: category
                            ).tag(category)
                        default:
                            PreviewTile(expanded: $expanded, category: category).tag(category)
                        }
                        
                    }
                    if categories.count < max {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color(uiColor: .systemFill))
                            HStack {
                                Spacer()
                                if !unusedColors.isEmpty {
                                    Button {
                                        let category = DACategory(context: moc, color: unusedColors[0])
                                        try! moc.save()
                                        
                                        expanded = category.id
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 3)
                        .frame(height: 65)
                    }
                    Spacer()
                }
                .navigationTitle("Categories")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    categories.nsPredicate = NSPredicate(format: "self != %@", DACategory.unassignedCategory!)
                }
            }
        }
    }
}

struct CategoryEditView_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    
    static var previews: some View {
        CategoryEditor()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
