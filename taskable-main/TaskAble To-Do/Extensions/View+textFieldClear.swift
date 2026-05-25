//
//  View+textFieldClearButton.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/29/22.
//

import SwiftUI

struct TextFieldClearModifier: ViewModifier {
    @Binding var textField: String
    @FocusState var focused: Bool
    
    var padding: EdgeInsets {
        if !textField.isEmpty {
            return EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 26
            )
        } else {
            return EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .overlay {
                if !textField.isEmpty && focused {
                    HStack {
                        Spacer()
                        Button {
                            textField = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        
                    }
                }
            }
            .focused($focused)
            .onSubmit {
                focused = false
            }
    }
}

extension View {
    func textFieldClearable(text: Binding<String>) -> some View {
        self.modifier(TextFieldClearModifier(textField: text))
    }
}
