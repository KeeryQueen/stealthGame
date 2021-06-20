//
//  DefaultFillFormatter.swift
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

/// Default formatter that calculates the position of the filled line.
@objc(ChartDefaultFillFormatter)
open class DefaultFillFormatter: NSObject, IFillFormatter
{
    public typealias Block = (
        _ dataSet: ILineChartDataSet,
        _ dataProvider: LineChartDataProvider) -> CGFloat
    
    @o