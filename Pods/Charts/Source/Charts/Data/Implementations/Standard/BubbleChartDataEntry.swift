//
//  BubbleDataEntry.swift
//  Charts
//
//  Bubble chart implementation: 
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class BubbleChartDataEntry: ChartDataEntry
{
    /// The size of the bubble.
    @objc open var size = CGFloat(0.0)
    
    public required init()
    {
        super.init()
    }
    
    /// - Parameters:
    ///   - x: The index on the x-axis.
    ///   - y: The value on the y-axis.
    ///   - size: The size of the bubble.
    @objc public init(x: Double, y: Double, size: