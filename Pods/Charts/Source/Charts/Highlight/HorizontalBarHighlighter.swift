//
//  HorizontalBarHighlighter.swift
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

@objc(HorizontalBarChartHighlighter)
open class HorizontalBarHighlighter: BarHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let barData = self.chart?.data as? BarChartData else { return nil }

        let pos = getValsForTouch(x: y, y: x)
        guard let high = getHighlight(xValue: Double(pos.y), x: y, y: x) else { return nil }

        if let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet,
            set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
               