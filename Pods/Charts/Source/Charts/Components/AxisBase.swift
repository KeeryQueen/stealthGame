//
//  AxisBase.swift
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

/// Base class for all axes
@objc(ChartAxisBase)
open class AxisBase: ComponentBase
{
    public override init()
    {
        super.init()
    }
    
    /// Custom formatter that is used instead of the auto-formatter if set
    private var _axisValueFormatter: IAxisValueFormatter?
    
    @objc open var labelFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var labelTextColor = NSUIColor.labelOrBlack
    
    @objc open var axisLineColor = NSUIColor.gray
    @objc open var axisLineWidth = CGFloat(0.5)
    @objc open var axisLineDashPhase = CGFloat(0.0)
    @objc open var axisLineDashLengths: [CGFloat]!
    
    @objc open var gridColor = NSUIColor.gray.withAlphaComponent(0.9)
    @objc open var gridLineWidth = CGFloat(0.5)
    @objc open var gridLineDashPhase = CGFloat(0.0)
    @objc open var gridLineDashLengths: [CGFloat]!
    @objc open var gridLineCap = CGLineCap.butt
    
    @objc open var drawGridLinesEnabled = true
    