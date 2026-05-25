//
//  Environment+rootContext.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/27/22.
//

import Foundation
import SwiftUI
import CoreData

private struct RootContextKey: EnvironmentKey {
    static let defaultValue = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
}

extension EnvironmentValues {
    var rootContext: NSManagedObjectContext {
        get {
            self[RootContextKey.self]
        }
        set {
            self[RootContextKey.self] = newValue
        }
    }
}
