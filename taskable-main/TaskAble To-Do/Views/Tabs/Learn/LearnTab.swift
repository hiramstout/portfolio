//
//  LearnTab.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/22/22.
//

import SwiftUI

struct LearnTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                ArticleTile()
            }
            .navigationTitle("Learn")
        }
    }
}

//struct LearnTab_Previews: PreviewProvider {
//    static let dataController = DataController(inMemory: true)
//    
//    static var previews: some View {
//        
//        LearnTab()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//    }
//}
