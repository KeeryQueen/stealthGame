//
//  XAxisRendererHorizontalBarChart.swift
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

open class XAxisRendererHorizontalBarChart: XAxisRenderer
{
    internal weak var chart: BarChartView?
    
    @objc public init(viewPortHandler: ViewPortHandler, xAxis: XAxis?, transformer: Transformer?, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self.chart = chart
    }
    
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer
        {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10 && !viewPortHandler.isFullyZoomedOutY
            {
                let p1 = transfor