//
//  YAxis.swift
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


/// Class representing the y-axis labels settings and its entries.
/// Be aware that not all features the YLabels class provides are suitable for the RadarChart.
/// Customizations that affect the value range of the axis need to be applied before setting data for the chart.
@objc(ChartYAxis)
open class YAxis: AxisBase
{
    @objc(YAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case outsideChart
        case insideChart
    }
    
    ///  Enum that specifies the axis a DataSet should be plotted against, either Left or Right.
    @objc
    public enum AxisD