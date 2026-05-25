//
//  Environment+Error.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/11/22.
//

import Foundation
import SwiftUI

private struct ErrKey: EnvironmentKey {
    static let defaultValue: Binding<DAError?> = .constant(nil)
}

extension EnvironmentValues {
    var err: Binding<DAError?> {
        get {
            self[ErrKey.self]
        }
        set {
            self[ErrKey.self] = newValue
        }
    }
}

