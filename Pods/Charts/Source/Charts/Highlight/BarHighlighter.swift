//
//  BarHighlighter.swift
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

@objc(BarChartHighlighter)
open class BarHighlighter: ChartHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard
            let barData = (self.chart as? BarChartDataProvider)?.barData,
            let high = super.getHighlight(x: x, y: y)
            else { return nil }
        
        let pos = getValsForTouch(x: x, y: y)

        if let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.x),
                                       yValue: Double(pos.y))
        }
        else
        {
            return high
        }
    }
    
    internal override func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }
    
    internal override var data: ChartData?
    {
        return (chart as? BarChartDataProvider)?.barData
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    ///
    /// - Parameters:
    ///   - high: the Highlight to work with looking for stacked values
    ///   - set:
    ///   - xIndex:
    ///   - yValue:
    /// - Returns:
    @objc open func getStackedHighlight(high: Highlight,
                                  set: IBarChartDataSet,
                                  xValue: Double,
                                  yValue: Double) -> Highlight?
    {
        guard
            let chart = self.chart as? BarLineScatterCandleBubbleChartDataProv