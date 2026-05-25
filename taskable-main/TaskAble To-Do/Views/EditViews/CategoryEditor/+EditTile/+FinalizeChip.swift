//
//  +FinalizeChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/21/22.
//

import SwiftUI

extension CategoryEditor.EditTile {
    struct FinalizeChip: View {
        @Environment(\.managedObjectContext) private var moc
        
        @ObservedObject var category: DACategory
        @Binding var expanded: UUID?
        var geo: GeometryProxy
        
        var body: some View {
            HStack(spacing: 2) {
                Button(role: .destructive) {
                    moc.delete(category)
                } label: {
                    ZStack {
                        
                        CustomCornerRect(
                            corners: .bottomLeading,
                            cornerRadius: 12)
                        .frame(
                            width: geo.size.width/2-4,
                            height: 40
                        ).foregroundColor(Color(uiColor: .tertiarySystemFill))
                        CustomCornerRect(
                            corners: .bottomLeading,
                            cornerRadius: 12)
                        .stroke(
                            Color(uiColor: .separator),
                            lineWidth: 2
                        ).frame(
                            width: geo.size.width/2-4,
                            height: 40
                        )
                        Label("Delete", systemImage: "trash")
                    }
                    .padding(.bottom, 3)
                    .frame(alignment: .center)
                }
                Button {
                    try? moc.save()
                    expanded = nil
                } label: {
                    ZStack {
                        CustomCornerRect(
                            corners: .bottomTrailing,
                            cornerRadius: 12)
                        .frame(
                            width: geo.size.width/2-4,
                            height: 40
                        ).foregroundColor(Color(uiColor: .tertiarySystemFill))
                        CustomCornerRect(
                            corners: .bottomTrailing,
                            cornerRadius: 12)
                        .stroke(
                            Color(uiColor: .separator),
                            lineWidth: 2
                        ).frame(
                            width: geo.size.width/2-4,
                            height: 40
                        )
                        Label("Done", systemImage: "checkmark.square.fill")
                    }
                    .padding(.bottom, 3)
                }
            }
        }
    }
}
