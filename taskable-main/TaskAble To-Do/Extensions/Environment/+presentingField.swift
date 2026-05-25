//
//  Environment+presentingTaskField.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/5/22.
//

import Foundation
import SwiftUI

private struct PresentingFieldKey: EnvironmentKey {
    static let defaultValue: Binding<TaskEditor.PresentingField?>? = .none
}

extension EnvironmentValues {
    var presentingField: Binding<TaskEditor.PresentingField?>? {
        get {
            self[PresentingFieldKey.self]
        }
        set {
            self[PresentingFieldKey.self] = newValue
        }
    }
}

