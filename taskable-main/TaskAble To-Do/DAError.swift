//
//  DAError.swift
//  TaskAble To-Do
//
//  Created by Hiram Stout on 12/8/22.
//

import Foundation
import UserNotifications

enum DAError: Error {
    case nsError(NSError)
    case unknownError(String)
}
