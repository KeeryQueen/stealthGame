//
//  BubbleChartDataSet.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


open class BubbleChartDataSet: BarLineScatterCandleBubbleChartDataSet, IBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    internal var _maxSize = CGFloat(0.0)
    
    open var maxSize: CGFloat { return _maxSize }
    @objc open var normalizeSizeEnabled: Bool = true
    open var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    open override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? BubbleChartDat