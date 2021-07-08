//
//  CombinedHighlighter.swift
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

@objc(CombinedChartHighlighter)
open class CombinedHighlighter: ChartHighlighter
{
    /// bar highlighter for supporting stacked highlighting
    private var barHighlighter: BarHighlighter?
    
    @objc public init(chart: CombinedChartDataProvider, barDataProvider: BarChartDataProvider)
    {
        super.init(chart: chart)
        
        // if there is BarData, creat