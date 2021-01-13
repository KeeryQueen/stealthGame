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
    
 