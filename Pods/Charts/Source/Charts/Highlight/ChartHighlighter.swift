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
    ///   - xValue:
    ///   - x:
    ///   - y:
    /// - Returns: The corresponding ChartHighlight for a given x-value and xy-touch position in pixels.
    @objc open func getHighlight(xValue xVal: Double, x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let chart = chart else { return nil }
        
        let closestValues = getHighlights(xValue: xVal, x: x, y: y)
        guard !closestValues.isEmpty else { return nil }
        
        let leftAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .left)
        let rightAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: .right)
        
        let axis: YAxis.AxisDependency = leftAxisMinDist < rightAxisMinDist ? .left : .right
        
        let detail = closestSelectionDetailByPixel(closestValues: closestValues, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    /// - Parameters:
    ///   - xValue: the transformed x-value of the x-touch position
    ///   - x: touch position
    ///   - y: touch position
    /// - Returns: A list of Highlight objects representing the entries closest to the given xVal.
    /// The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
    @objc open func getHighlights(xVal