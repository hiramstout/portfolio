//
//  CornerOptionSet.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/6/22.
//

struct Corners: OptionSet {
    let rawValue: Int
    
    static let topLeading     = Corners(rawValue: 1 << 0)
    static let topTrailing    = Corners(rawValue: 1 << 1)
    static let bottomLeading  = Corners(rawValue: 1 << 2)
    static let bottomTrailing = Corners(rawValue: 1 << 3)
    
    static let top: Self      = [.topLeading, .topTrailing]
    static let bottom: Self   = [.bottomLeading, .bottomTrailing]
    static let leading: Self  = [.topLeading, .bottomLeading]
    static let trailing: Self = [.topTrailing, .bottomTrailing]
    static let all: Self      = [.top, .bottom]
}
