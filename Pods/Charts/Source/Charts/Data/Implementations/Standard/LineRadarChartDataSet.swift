//
//  LineRadarChartDataSet.swift
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


open class LineRadarChartDataSet: LineScatterCandleRadarChartDataSet, ILineRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// The color that is used for filling the line surface area.
    private var _fillColor = NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    /// The color that is used for filling the line surface area.
    open var fillColor: NSUIColor
    {
        get { return _fillColor }
        set
        {
            _fillColor = newValue
            fill = nil
        }
    }
    
    /// The object that is used for filling the area below the line.
    /// **default**: nil
    open var fill: Fill?
    
    /// The alpha value that is used for filling the line surface,
    /// **default**: 0.33
    open var fillAlpha = CGFloat(0.33)
    
    private var _lineWidth = CGFloat(1.0)
    
    /// line width of the chart (min = 0.0, max = 10)
    ///
    /// **default**: 1
    open var lineWidth: CGFloat
    {
        get
        {
            return _lineWidth
        }
        set
        {
  