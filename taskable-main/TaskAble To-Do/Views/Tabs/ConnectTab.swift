//
//  ConnectTab.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/22/22.
//

import SwiftUI

struct ConnectTab: View {
    var body: some View {
        Text("")
    }
}

struct ConnectTab_Previews: PreviewProvider {
    static let dataController = DataController(inMemory: true)
    
    static var previews: some View {
        ConnectTab()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
