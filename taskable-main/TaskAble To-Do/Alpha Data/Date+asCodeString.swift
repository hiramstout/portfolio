//
//  Date+asCodeString.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/10/22.
//

import Foundation

extension Date {
    var codeString: String {
        "Date(timeIntervalSince1970: \(timeIntervalSince1970)"
    }
}
