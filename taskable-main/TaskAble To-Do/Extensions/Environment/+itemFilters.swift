//
//  Environment+itemFilters.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/3/22.
//

import Foundation
import SwiftUI
import CoreData

private struct ItemFiltersKey: EnvironmentKey {
    static let defaultValue: Binding<[TaskList.Filters]>? = .none
}

extension EnvironmentValues {
    var itemFilters: Binding<[TaskList.Filters]>? {
        get {
            self[ItemFiltersKey.self]
        }
        set {
            self[ItemFiltersKey.self] = newValue
        }
    }
}

