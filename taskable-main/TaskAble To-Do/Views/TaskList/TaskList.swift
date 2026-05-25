//
//  TaskList.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/22/22.
//

import SwiftUI
import CoreData

struct TaskList: View {
    @Environment(\.itemFilters) var filters
    @Environment(\.sortOptions) var sortOptions
    
    @Environment(\.managedObjectContext) private var moc
    
    @StateObject var taskConfig = ChildContextConfig<DATask>()
    
    @State private var items: [DAItem] = []
    @State private var presentingTaskSheet: Bool = false
    
    private let didUpdate: NotificationCenter.Publisher = {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    }()
    
    func updateList() {
        let request = DAItem.fetchRequest()
        guard let compiledFilters = filters?.wrappedValue.map({$0.filter}) else {
            return
        }
        let compound = NSCompoundPredicate(type: .and, subpredicates: compiledFilters)
        request.predicate = compound
        guard let sortDescriptors = sortOptions?.wrappedValue.nsDescriptors else {
            return
        }
        request.sortDescriptors = sortDescriptors
        let results = try! moc.fetch(request)
        items = results.map {$0}
    }
    
    var body: some View {
        VStack {
            ScrollView {
                if items.isEmpty {
                    EmptyView()
                } else {
                    ForEach($items, id: \.id) { $item in
                        TaskTile(task: item as! DATask)
                            .tag(item.id)
                    }
                }
                
                
                Button {
                    taskConfig.updateObject(usingParent: moc, usingFilters: filters?.wrappedValue ?? [])
                    presentingTaskSheet = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color(uiColor: .systemFill))
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 3)
                .frame(height: 65)
            }
        }
        .sheet(isPresented: $presentingTaskSheet) {
            try! moc.save()
            updateList()
        } content: {
            TaskEditor(taskConfig: taskConfig)
                .environment(\.managedObjectContext, taskConfig.childContext)
        }
        .onChange(of: filters?.wrappedValue) { _ in
            updateList()
        }
        .onChange(of: sortOptions?.wrappedValue.options) { _ in
            updateList()
        }
        .onReceive(didUpdate) { _ in
            DispatchQueue.main.asyncAfter(wallDeadline: .now(), qos: .userInteractive) {
                withAnimation(.easeOut) {
                    updateList()
                }
            }
        }
        .onAppear {
            updateList()
        }
    }
    
}

//struct TaskList_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//
//    static var previews: some View {
//        TaskList()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//            .preferredColorScheme(.dark)
//    }
//} description    String    "category == \"B4399C58-113D-45B9-8E9E-188434F62C33\""
