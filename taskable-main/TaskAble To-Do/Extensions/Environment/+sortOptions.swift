//
//  Environment+sortOptions.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/3/22.
//

import Foundation

import Foundation
import SwiftUI
import CoreData

private struct SortOptionsKey: EnvironmentKey {
    static let defaultValue: Binding<TaskList.SortOptions>? = .none
}

extension EnvironmentValues {
    var sortOptions: Binding<TaskList.SortOptions>? {
        get {
            self[SortOptionsKey.self]
        }
        set {
            self[SortOptionsKey.self] = newValue
        }
    }
}
