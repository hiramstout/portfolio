//
//  +PortholeListView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/28/22.
//

import SwiftUI

extension TaskTile {
    
    struct PortholeList: View {
        var portholes: [DATask.Porthole]
        struct CapsuleViewModifier: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .padding(EdgeInsets(
                        top: 0,
                        leading: 8,
                        bottom: 4,
                        trailing: 0))
                    .frame(height: 34, alignment: .top)
            }
        }
        
        var body: some View {
            ZStack {
                Capsule(style: .circular)
                    .foregroundStyle(.ultraThinMaterial)
                    .modifier(CapsuleViewModifier())
                Capsule(style: .circular)
                    .stroke(
                        Color(uiColor: .separator),
                        lineWidth: 2.0)
                    .backgroundStyle(.opacity(1))
                    .modifier(CapsuleViewModifier())
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .center) {
                        ForEach(portholes, id: \.id) { porthole in
                            TaskTile.Porthole(porthole: porthole)
                        }
                    }
                }
                .mask {
                    Capsule(style: .circular)
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: 11,
                    bottom: 4,
                    trailing: 3
                ))
            }
        }
    }
}

struct TaskListTileView_Porthole_Previews: PreviewProvider {
    
    static var previews: some View {
        TaskTile.PortholeList(portholes: PreviewData.tasks[0].portholes)
            .frame(width: 200)
    }
}
