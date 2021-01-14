//
//  Legend.swift
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

@objc(ChartLegend)
open class Legend: ComponentBase
{
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        /// Avoid drawing a form
        case none
        
        /// Do not draw the a form, but leave space for it
        case empty
        
        /// Use default (default dataset's form to the legend's form)
        case `default`
        
        /// Draw a square
        case square
        
        /// Draw a circle
        case circle
        
        /// Draw a horizontal line
        case line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case left
        case center
        case right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case top
        case center
        case bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case horizontal
        case vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case leftToRight
        case rightToLeft
    }
    
    /// The legend entries array
    @objc open var entries = [LegendEntry]()
    
    /// Entries that will be appended to the end of the auto calculated entries after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    @objc open var extraEntries = [LegendEntry]()
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    private var _isLegendCustom = false

    /// The horizontal alignment of the legend
    @objc open var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.left
    
    /// The vertical alignment of the legend
    @objc open var verticalAlignment: VerticalAlignment = VerticalAlignment.bottom
    
    /// The orientation of the legend
    @objc open var orientation: Orientation = Orientation.horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    @objc open var drawInside: Bool = false
    
    /// Flag indicating whether the 