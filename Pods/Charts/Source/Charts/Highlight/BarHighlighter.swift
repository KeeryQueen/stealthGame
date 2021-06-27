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
        
        let pos = getValsForTouch(x: x,