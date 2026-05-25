//
//  +TilePreview.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/5/22.
//

import SwiftUI

extension CategoryEditor {
    struct PreviewTile: View {
        @Environment(\.colorScheme) private var colorScheme
        
        @Binding var expanded: UUID?
        var category: DACategory
        
        private let background = RoundedRectangle(cornerRadius: 12)
        private let vSpacerWidth: CGFloat = 34
        
        var tileBackground: String {
            return category.color.rawValue
        }
        
        var body: some View {
            HStack(alignment: .center) {
                Text(category.title)
                    .foregroundColor(.init(white: 0.3))
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .padding(.leading, 30)
                Spacer(minLength: vSpacerWidth)
                Button {
                    withAnimation {
                        expanded = category.id
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .padding(.trailing, 30)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.thickMaterial)
                }

                
                // TODO: Down chevron for children
            }
            .frame(height: 65)
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
//
//struct _TilePreview_Previews: PreviewProvider {
//
//    @State static var category = PreviewData.Categories.home.category
//    @State static var expanded: UUID? = nil
//    
//    static var previews: some View {
//        CategoryEditor.PreviewTile(expanded: .constant(expanded), category: category)
//    }
//}
