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
    /// - Returns: The corresponding x-pos for a given touch-position in pixels.
    @objc open func getValsForTouch(x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider else { return .zero }
        
        // take any transformer to determine the values
        return chart.getTransformer(forAxis: .left).valueForTouchPoint(x: x, y: y)
    }
    
    /// - Parameters:
    //