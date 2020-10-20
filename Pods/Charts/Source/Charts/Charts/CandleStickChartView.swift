//
//  CandleStickChartView.swift
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

/// Financial chart type that draws candle-sticks.
open class CandleStickChartView: BarLineChartViewBase, CandleChartDataProvider
{
    internal override func initialize()
    {
        super.initialize()
        
    