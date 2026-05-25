//
//  TaskListItemView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/23/22.
//

import SwiftUI
import CoreData

struct TaskTile: View, Animatable {
    typealias AnimatableData = CGFloat
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var task: DATask
    
    @StateObject var taskConfig = ChildContextConfig<DATask>()
    
    @State var animatableData: AnimatableData = 0
    @State private var presentingEditMode: Bool = false
    @State private var category: DACategory = .unassignedCategory!
    
    private let background = RoundedRectangle(cornerRadius: 12)
    private let vSpacerWidth: CGFloat = 34
    private var portholes: [DATask.Porthole] {
        task.portholes
    }
    
    var tileBackground: String {
        return task.category?.color.rawValue ?? DACategory.DAColor.unassigned.rawValue
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                
                HStack(alignment: .center) {
                    VStack {
                        HStack(alignment: .top) {
                            Spacer()
                            Text(task.title)
                                .opacity(0)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .padding(EdgeInsets(
                                    top: 4,
                                    leading: 8,
                                    bottom: 0,
                                    trailing: 6))
                                
                            Spacer()
                        }
                        .frame(
                            height: 18,
                            alignment: .top)
                        PortholeList(portholes: task.portholes)
                    }
                    
                    Spacer(minLength: vSpacerWidth)
                    // TODO: Down chevron for children
                    VStack {
                        Spacer()
                        FinishCircleChip(animatableData: $animatableData)
                            .Placeholder
                        Spacer()
                    }
                    .environmentObject(task)
                    
                }
                Rectangle()
                    .clipShape(
                        RoundedRectangle(cornerRadius: 9)
                    )
                    .padding(.all, 2)
                    .frame(width: animatableData * geo.size.width)
                    .foregroundColor(Color(
                        uiColor: .systemBackground.withAlphaComponent(0.8)
                    ))
                HStack {
                    VStack {
                        HStack(alignment: .top) {
                            Spacer()
                            Text(task.title)
                                .foregroundColor(colorScheme == .light ? Color(white: 0.3) : Color(white: 0.2))
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .padding(EdgeInsets(
                                    top: 4,
                                    leading: 8,
                                    bottom: 0,
                                    trailing: 6))
                            Spacer()
                        }
                        .frame(
                            height: 18,
                            alignment: .top)
                        Rectangle()
                            .padding(EdgeInsets(
                                top: 0,
                                leading: 8,
                                bottom: 4,
                                trailing: 0))
                            .frame(height: 34, alignment: .top)
                            .opacity(0)
                    }
                    Spacer(minLength: vSpacerWidth)
                    VStack {
                        Spacer()
                        FinishCircleChip(animatableData: $animatableData)
                        Spacer()
                    }
                    .environmentObject(task)
                }
            }
        }
        .frame(height: 65)
        .background {
            background
                .foregroundStyle(Color(tileBackground))
            background
                .stroke(.thinMaterial, lineWidth: 5)
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $presentingEditMode) {
            try! moc.save()
        } content: {
            TaskEditor(taskConfig: taskConfig)
                .environment(\.managedObjectContext, taskConfig.childContext)
        }
        .onTapGesture {
            presentingEditMode = true
        }
        .onAppear {
            taskConfig.updateObject(to: task, newContextWithParent: moc)
            if task.status == .completed {
                animatableData = 1
            }
        }
    }
}

struct TaskListTileView_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    static var task = {
        let request: NSFetchRequest<DATask> = DATask.fetchRequest()
        request.predicate = NSPredicate(format: "cdTitle CONTAINS[cd] %@", "randy")
        let result = try! dataController.container.viewContext.fetch(request)
        if !result.isEmpty {
            let task = result[0]
            return task
        } else {
            fatalError()
        }
    }()
    
    static var previews: some View {
        VStack {
            Spacer()
            TaskTile(task: task)
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .environment(\.managedObjectContext, dataController.container.viewContext)
        .environment(\.rootContext, dataController.container.viewContext)
        .preferredColorScheme(.dark)
    }
}
