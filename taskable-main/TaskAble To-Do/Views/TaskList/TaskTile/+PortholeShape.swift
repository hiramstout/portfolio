//
//  TLTV+PortholeShape.swift
//  DreamAble
//
//  Created by Hiram Stout on 10/25/22.
//

import SwiftUI

extension TaskTile {
    struct PortholeShape: Shape {
        func path(in rect: CGRect) -> Path {
            let radius = rect.height / 2
            let circleCenter = rect.width - radius
            let startY = sqrt(
                (radius*radius)
                - (circleCenter*circleCenter)
            )
            let startAngle: Angle
            var endAngle: Angle {
                -startAngle
            }
            var path = Path()
            
            if circleCenter > 0 {
                startAngle = Angle(degrees: 90)
            } else {
                let angleRadians = atan2(-startY, -(rect.width-circleCenter))
                startAngle = Angle(radians: angleRadians)
            }
            
            path.addArc(
                center: CGPoint(
                    x: circleCenter + rect.origin.x,
                    y: rect.origin.y + radius
                ),
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            
            if circleCenter > 0 {
                path.addLine(to: rect.origin)
            }
            var topLeft = rect.origin
            topLeft.y = rect.height
            path.addLine(to: topLeft)
            path.closeSubpath()
            
            return path
        }
    }
}
