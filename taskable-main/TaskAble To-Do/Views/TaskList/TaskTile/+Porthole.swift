//
//  TLTV+PortholeView.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/25/22.
//

import SwiftUI

extension TaskTile {
    struct Porthole: View {
        var porthole: DATask.Porthole
        @Environment(\.colorScheme) private var colorScheme
        
        var windowColor: Color {
            switch porthole {
            case .dueDate:
                return Color(
                    uiColor: (colorScheme == .light ) ?
                        .tertiaryLabel : .secondaryLabel.withAlphaComponent(0.6))
            case .tag:
                return Color(uiColor: .tertiaryLabel)
            case .priority:
                return Color(
                    uiColor: (colorScheme == .light ) ?
                        .tertiaryLabel : .label.withAlphaComponent(0.7))
            default:
                return Color(uiColor: .tertiaryLabel)
            }
        }
        
        var body: some View {
            ZStack {
                Capsule()
                    .frame(minWidth: 50, minHeight: 24, maxHeight: 24, alignment: .top)
                    .foregroundColor(porthole.color)
                Capsule()
                    .strokeBorder(Color(uiColor: .secondarySystemFill), style: StrokeStyle(lineWidth: 2))
                
                    .frame(minWidth: 50, minHeight: 24, maxHeight: 24, alignment: .top)
                    
                HStack {
                    porthole.symbol
                        .frame(
                            width: 15,
                            alignment: .leading
                        )
                        .padding(.leading, 0)
                        .padding(porthole.symbolPadding)
                        .font(.system(size: 19))
                    Spacer()
                    ZStack {
                        CustomCornerRect(
                            corners: .trailing,
                            cornerRadius: 9)
                        .frame(
                            height: 18,
                            alignment: .trailing)
                        .padding(.trailing, 2)
                        .foregroundColor(windowColor)
                        HStack {
                            porthole.label
                                .frame(alignment: .leading)
                                .padding(.leading, 4)
                            Spacer()
                        }
                    }
                    
                }
                .padding(.trailing, 1)
                .padding(.leading, 1)
                
            }
            .fixedSize()
        }
    }
}
