//
//  +unAuthorized.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/11/22.
//

import Foundation
import SwiftUI

private struct UNAuthorizedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var unAuthorized: Binding<Bool> {
        get {
            self[UNAuthorizedKey.self]
        }
        set {
            self[UNAuthorizedKey.self] = newValue
        }
    }
}
