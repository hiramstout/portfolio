//
//  RowInsetToggle.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 2/19/23.
//

import Foundation
import SwiftUI

struct AnimatingCellHeight: Animatable, ViewModifier {
    var height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
    }
    
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
                .frame(height: animatableData, alignment: .top)
                .clipped()
                .disabled(height == 0)
        }
    }
}

struct ExpandableRowContent<EditorInset: View>: ViewModifier {
    var editorInset: EditorInset
    var height: CGFloat
    
    init(height: CGFloat, @ViewBuilder _ editorInset: ()->EditorInset) {
        self.editorInset = editorInset()
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.top, 5)
            .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
            .padding(.horizontal, 7)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                editorInset
                    .padding(.top, 4)
                    .modifier(AnimatingCellHeight(height: height))
            }
    }
}

extension View {
    func expandableRowContent<EditorInset: View>(
        height: CGFloat,
        @ViewBuilder _ editorInset: ()->EditorInset
    ) -> some View {
        self.body
            .modifier(ExpandableRowContent(height: height, editorInset))
            .padding(.top, 6)
            .animation(.easeInOut, value: height)
    }
}

