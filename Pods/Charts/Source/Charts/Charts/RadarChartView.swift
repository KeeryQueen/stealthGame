
//
//  RadarChartView.swift
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


/// Implementation of the RadarChart, a "spidernet"-like chart. It works best
/// when displaying 5-10 entries per DataSet.
open class RadarChartView: PieRadarChartViewBase
{
    /// width of the web lines that come from the center.
    @objc open var webLineWidth = CGFloat(1.5)
    
    /// width of the web lines that are in between the lines coming from the center
    @objc open var innerWebLineWidth = CGFloat(0.75)
    
    /// color for the web lines that come from the center
    @objc open var webColor = NSUIColor(red: 122/255.0, green: 122/255.0, blue: 122.0/255.0, alpha: 1.0)
    
    /// color for the web lines in between the lines that come from the center.
    @objc open var innerWebColor = NSUIColor(red: 122/255.0, green: 122/255.0, blue: 122.0/255.0, alpha: 1.0)
    
    /// transparency the grid is drawn with (0.0 - 1.0)
    @objc open var webAlpha: CGFloat = 150.0 / 255.0
    
    /// flag indicating if the web lines should be drawn or not
    @objc open var drawWeb = true
    
    /// modulus that determines how many labels and web-lines are skipped before the next is drawn
    private var _skipWebLineCount = 0
    
    /// the object reprsenting the y-axis labels
    private var _yAxis: YAxis!
    
    internal var _yAxisRenderer: YAxisRendererRadarChart!
    internal var _xAxisRenderer: XAxisRendererRadarChart!
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    internal override func initialize()
    {
        super.initialize()
        
        _yAxis = YAxis(position: .left)
        _yAxis.labelXOffset = 10.0
        
        renderer = RadarChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        _yAxisRenderer = YAxisRendererRadarChart(viewPortHandler: _viewPortHandler, yAxis: _yAxis, chart: self)
        _xAxisRenderer = XAxisRendererRadarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, chart: self)
        
        self.highlighter = RadarHighlighter(chart: self)
    }

    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        guard let data = _data else { return }
        
        _yAxis.calculate(min: data.getYMin(axis: .left), max: data.getYMax(axis: .left))
        _xAxis.calculate(min: 0.0, max: Double(data.maxEntryCountSet?.entryCount ?? 0))
    }
    
    open override func notifyDataSetChanged()
    {
        calcMinMax()

        _yAxisRenderer?.computeAxis(min: _yAxis._axisMinimum, max: _yAxis._axisMaximum, inverted: _yAxis.isInverted)
        _xAxisRenderer?.computeAxis(min: _xAxis._axisMinimum, max: _xAxis._axisMaximum, inverted: false)
        
        if let data = _data,
            let legend = _legend,
            !legend.isLegendCustom
        {
            legendRenderer?.computeLegend(data: data)
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }