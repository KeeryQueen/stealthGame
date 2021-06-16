//
//  DataApproximator+N.swift
//  Charts
//
//  Created by M Ivaniushchenko on 9/6/17.
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

extension CGPoint {
    fileprivate func distanceToLine(from linePoint1: CGPoint, to linePoint2: CGPoint) -> CGFloat {
        let dx = linePoint2.x - linePoint1.x
        let dy = linePoint2.y - linePoint1.y
        
        let dividend = abs(dy * self.x - dx * self.y - linePoint1.x * linePoint2.y + linePoint2.x * linePoint1.y)
        let divisor = sqrt(dx * dx + dy * dy)
        
        return dividend / divisor
    }
}

private struct LineAlt {
    let start: Int
    let end: Int
    
    var distance: CGFloat = 0
    var index: Int = 0
    
    init(start: Int, end: Int, points: [CGPoint]) {
        self.start = start
        self.end = end
        
        let startPoint = points[start]
        let endPoint = points[end]
        
        guard (end > start + 1) else {
            return
        }
        
        for i in start + 1 ..< end {
            let currentPoint = points[i]
            
            let distance = currentPoint.distanceToLine(from: startPoint, to: endPoint)
            
            if distance > self.distance {
                self.index = i
                self.distance = distance
            }
        }
    }
}

extension LineA