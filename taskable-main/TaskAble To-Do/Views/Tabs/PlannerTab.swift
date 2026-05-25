//
//  Planner.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/20/22.
//

import SwiftUI

struct PlannerTab: View {
    var body: some View {
        Text("Planner")
    }
}

struct PlannerTab_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    
    static var previews: some View {
        PlannerTab()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
