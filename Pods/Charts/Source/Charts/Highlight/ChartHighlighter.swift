//
//  ChartHighlighter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class ChartHighlighter : NSObject, IHighlighter
{
    /// instance of the data-provider
    @objc open weak var chart: ChartDataProvider?
    
    @objc public init(chart: ChartDataProvider)
    {
        self.chart = chart
    }
    
    open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        return getHighlight(xValue: xVal, x: x, y: y)
    }
    
    /// - Parameters:
    ///   - x:
    /// 