//
//  TilePreviewEditView.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/5/22.
//

import SwiftUI
import CoreData

extension CategoryEditor {

    struct EditTile: View {
        // TODO: Done, Delete
        @Binding var expanded: UUID?
        
        @ObservedObject  var category: DACategory
        
        private let background = RoundedRectangle(cornerRadius: 12)
        private let vSpacerWidth: CGFloat = 34
        
        var tileBackground: String {
            return category.color.rawValue
        }
        
        var body: some View {
            VStack {
                HStack(alignment: .center) {
                    TitleChip(category: category)
                    Spacer(minLength: vSpacerWidth)
                    Button {
                        withAnimation {
                            expanded = nil
                        }
                    } label: {
                        Image(systemName: "chevron.up.circle.fill")
                            .padding(.trailing, 30)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.thickMaterial)
                    }
                    // TODO: Down chevron for children
                }
                .padding(.top, 10)
                Spacer()
                    .frame(height: 7)
                GeometryReader { geo in
                    ZStack {
                        CustomCornerRect(corners: [.bottom], cornerRadius: 12)
                            .background {
                                VStack {
                                    Rectangle()
                                        .padding(.horizontal, 2)
                                        .frame(width: geo.size.width, height: 3)
                                        .foregroundColor(Color(uiColor: .separator))
                                    Spacer()
                                }
                            }
                            .foregroundColor(Color(uiColor: UIColor.systemFill))
                            .padding([.horizontal, .bottom], 2)
                        VStack {
                            Form {
                                ColorPickerChip(category: category)
                            }
                            .scrollContentBackground(.hidden)
                            FinalizeChip(
                                category: category,
                                expanded: $expanded,
                                geo: geo
                            )
                            
                        }
                    }
                }
            }
            .frame(height: 200)
            .background {
                background
                    .foregroundStyle(Color(tileBackground))
                background
                    .stroke(.thinMaterial, lineWidth: 5)
            }
            .padding(.horizontal, 10)
        }
    }
}

//struct TilePreviewEditView_Previews: PreviewProvider {
//    static let id = UUID()
//    @State static var presented: UUID? = nil
//    
//    static var previews: some View {
//        CategoryEditor.EditTile(categoryID: UUID(), expanded: $presented)
//    }
//}
