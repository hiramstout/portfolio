//
//  Environment+navRoute.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/8/22.
//

import Foundation
import SwiftUI

private struct NavRouteKey: EnvironmentKey {
    static let defaultValue: Binding<[ManageTab.NavRoute]>? = .none
}

extension EnvironmentValues {
    var navRoute: Binding<[ManageTab.NavRoute]>? {
        get {
            self[NavRouteKey.self]
        }
        set {
            self[NavRouteKey.self] = newValue
        }
    }
}
