//
//  CustomCornerRectangle.swift
//  DreamAble
//
//  Created by Hiram Stout on 11/6/22.
//

import SwiftUI

struct CustomCornerRect: InsettableShape {
    func inset(by amount: CGFloat) -> CustomCornerRect {
        CustomCornerRect(corners: self.corners, cornerRadius: self.cornerRadius - amount)
    }
    
    typealias InsetShape = Self
    
    let corners: Corners
    let cornerRadius: CGFloat
    
    func resolvedRadius(rect: CGRect) -> CGFloat {
        if cornerRadius > rect.width/2 || cornerRadius > rect.height/2 {
            if rect.width < rect.height {
                return rect.width/2
            } else {
                return rect.height/2
            }
        } else {
            return cornerRadius
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let radius = resolvedRadius(rect: rect)
        var path = Path()
        var startPoint = rect.origin
        startPoint.x = rect.width/2
        path.move(to: startPoint)
        
        // Top trailing line
        if radius != rect.width/2 {
            var point = rect.origin
            point.x += rect.width - radius
            path.addLine(to: point)
        }
        
        // Top trailing corner
        if corners.contains(.topTrailing) {
            var center = rect.origin
            center.x += rect.width - radius
            center.y += radius
            path.addRelativeArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: 270),
                delta: Angle(degrees: 90)
            )
        } else {
            var point: CGPoint = rect.origin
            point.x += rect.width
            path.addLine(to: point)
            point.y += radius
            path.addLine(to: point)
        }
        
        // Trailing line
        if radius != rect.height/2 {
            var toPoint = rect.origin
            toPoint.x += rect.width
            toPoint.y += rect.height - radius
            path.addLine(to: toPoint)
        }
        
        // Bottom trailing corner
        if corners.contains(.bottomTrailing) {
            var center = rect.origin
            center.x += rect.width-radius
            center.y += rect.height-radius
            path.addRelativeArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: 0),
                delta: Angle(degrees: 90)
            )
        } else {
            var point = rect.origin
            point.x += rect.width
            point.y += rect.height
            path.addLine(to: point)
            point.x -= radius
            path.addLine(to: point)
        }
        
        // Bottom line
        if radius != rect.width/2 {
            var point = rect.origin
            point.x += radius
            point.y += rect.height
            path.addLine(to: point)
        }
        
        // Bottom leading corner
        if corners.contains(.bottomLeading) {
            var center = rect.origin
            center.x += radius
            center.y += rect.height - radius
            path.addRelativeArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: 90),
                delta: Angle(degrees: 90)
            )
        } else {
            var point = rect.origin
            point.y += rect.height
            path.addLine(to: point)
            point.y -= radius
            path.addLine(to: point)
        }
        
        // Leading line
        if radius != rect.height/2 {
            var point = rect.origin
            point.y += radius
            path.addLine(to: point)
        }
        
        // Top leading corner
        if corners.contains(.topLeading) {
            var center = rect.origin
            center.y += radius
            center.x += radius
            path.addRelativeArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: 180),
                delta: Angle(degrees: 90)
            )
            
        } else {
            path.addLine(to: rect.origin)
            var point = rect.origin
            point.x += radius
            path.addLine(to: point)
        }
        
        path.closeSubpath()
        return path
        // Bottom leading line
    }
}
