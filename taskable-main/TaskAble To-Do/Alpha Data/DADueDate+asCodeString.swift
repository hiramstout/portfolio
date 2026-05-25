//
//  DADueDate+asCodeString.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/10/22.
//

import Foundation

extension DATask.DueDate {
    var codeString: String {
        switch self {
        case .strict(let date):
            return ".strict(Date(timeIntervalSince1970: \(date.timeIntervalSince1970)))"
        default:
            return ""
        }
    }
}
