
//
//  XAxis.swift
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

@objc(ChartXAxis)
open class XAxis: AxisBase
{
    @objc(XAxisLabelPosition)
    public enum LabelPosition: Int
    {
        case top
        case bottom
        case bothSided
        case topInside
        case bottomInside
    }
    
    /// width of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    @objc open var labelWidth = CGFloat(1.0)
    
    /// height of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    @objc open var labelHeight = CGFloat(1.0)
    
    /// width of the (rotated) x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers