//
//  Date+Identifiable.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 11/20/22.
//

import Foundation

extension Date: Identifiable {
    public var id: Double {
        self.timeIntervalSince1970
    }
}
