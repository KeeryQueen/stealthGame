//
//  PieRadarHighlighter.swift
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

@objc(PieRadarChartHighlighter)
open class PieRadarHighlighter: ChartHighlighter
{    
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let chart = self.chart as? PieRadarChartViewBase else { return nil }
        
        let touchDistanceToCenter = chart.distanceToCenter(x: x, y: y)
        
        // check if a slice was touched
        guard touchDistanceToCenter <= chart.radius else
        {
