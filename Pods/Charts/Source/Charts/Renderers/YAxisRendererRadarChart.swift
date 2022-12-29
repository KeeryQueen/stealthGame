//
//  YAxisRendererRadarChart.swift
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

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

open class YAxisRendererRadarChart: YAxisRenderer
{
    private weak var chart: RadarChartView?
    
    @objc public init(viewPortHandler: ViewPortHandler, yAxis: YAxis?, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: nil)
        
        self.chart = chart
    }
    
    open override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        guard let
            axis = axis as? YAxis
            else { return }
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        if labelCount == 0 || range <= 0 || range.isInfinite
        {
            axis.entries = [Double]()
            a