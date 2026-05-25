//
//  +TitleChip.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/21/22.
//

import SwiftUI

extension CategoryEditor.EditTile {
    struct TitleChip: View {
        @Environment(\.colorScheme) private var colorScheme
        
        @StateObject var category: DACategory
        
        @FocusState private var focus: Bool
        @State private var title: String = ""
        @State private var editingTitle: Bool = false
        
        var foregroundStyle: Material {
            (colorScheme == .light) ? .thickMaterial : .ultraThinMaterial
        }
        
        var titleEditBar: some View {
            ZStack {
                VStack {
                    Spacer()
                    Rectangle()
                        .foregroundStyle(foregroundStyle)
                        .frame(height: 3)
                        .padding(.leading, 20)
                }
                if !editingTitle {
                    HStack {
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundStyle(foregroundStyle)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        
        var body: some View {
            ZStack {
                if !editingTitle {
                    Button {
                        editingTitle.toggle()
                    } label: {
                        Text(category.title)
                            .foregroundColor(.init(white: 0.3))
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .padding(.leading, 30)
                            .padding(.trailing, 25)
                            .overlay {
                                titleEditBar
                            }
                    }
                } else {
                    TextField("Title", text: $title)
                        .focused($focus)
                        .foregroundColor(Color(white: 0.3))
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .frame(width: 100)
                        .padding(.leading, 30)
                        .padding(.trailing, 25)
                        .overlay {
                            titleEditBar
                        }
                        .onChange(of: title) { newValue in
                            category.title = newValue
                        }
                }
            }
            .onAppear {
                if category.title == "" {
                    focus = true
                    editingTitle = true
                } else  {
                    self.title = category.title
                }
            }
        }
    }
}
