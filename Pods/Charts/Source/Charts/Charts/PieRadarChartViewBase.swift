
//
//  PieRadarChartViewBase.swift
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
import QuartzCore

#if canImport(AppKit)
import AppKit
#endif


/// Base class of PieChartView and RadarChartView.
open class PieRadarChartViewBase: ChartViewBase
{
    /// holds the normalized version of the current rotation angle of the chart
    private var _rotationAngle = CGFloat(270.0)
    
    /// holds the raw version of the current rotation angle of the chart
    private var _rawRotationAngle = CGFloat(270.0)
    
    /// flag that indicates if rotation is enabled or not
    @objc open var rotationEnabled = true
    
    /// Sets the minimum offset (padding) around the chart, defaults to 0.0
    @objc open var minOffset = CGFloat(0.0)

    /// iOS && OSX only: Enabled multi-touch rotation using two fingers.
    private var _rotationWithTwoFingers = false
    
    private var _tapGestureRecognizer: NSUITapGestureRecognizer!
    #if !os(tvOS)
    private var _rotationGestureRecognizer: NSUIRotationGestureRecognizer!
    #endif
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        stopDeceleration()
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        
        self.addGestureRecognizer(_tapGestureRecognizer)

        #if !os(tvOS)
        _rotationGestureRecognizer = NSUIRotationGestureRecognizer(target: self, action: #selector(rotationGestureRecognized(_:)))
        self.addGestureRecognizer(_rotationGestureRecognizer)
        _rotationGestureRecognizer.isEnabled = rotationWithTwoFingers
        #endif
    }
    
    internal override func calcMinMax()
    {
        /*_xAxis.axisRange = Double((_data?.xVals.count ?? 0) - 1)*/
    }
    
    open override var maxVisibleCount: Int
    {
        get
        {
            return data?.entryCount ?? 0
        }
    }
    
    open override func notifyDataSetChanged()
    {
        calcMinMax()
        
        if let data = _data , _legend !== nil
        {
            legendRenderer.computeLegend(data: data)
        }
        
        calculateOffsets()
        