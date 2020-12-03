//
//  HorizontalBarChartView.swift
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

/// BarChart with horizontal bar orientation. In this implementation, x- and y-axis are switched.
open class HorizontalBarChartView: BarChartView
{
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        renderer = HorizontalBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        leftYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: leftAxis, transformer: _leftAxisTransformer)
        rightYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: rightAxis, transformer: _rightAxisTransformer)
        xAxisRenderer = XAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = HorizontalBarHighlighter(chart: self)
    }
    
    internal override func calculateLegendOffsets(offsetLeft: inout CGFloat, offsetTop: inout CGFloat, offsetRight: inout CGFloat, offsetBottom: inout CGFloat)
    {
        guard
            let legend = _legend,
            legend.isEnabled,
            !legend.drawInside
        else { return }
        
        // setup offsets for legend
        switch legend.orientation
        {
        case .vertical:
            switch legend.horizontalAlignment
            {
            case .left:
                offsetLeft += min(legend.neededWidth, _viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                
            case .right:
                offsetRight += min(legend.neededWidth, _viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset
                
            case .center:
                
                switch legend.verticalAlignment
                {
                case .top:
                    offsetTop += min(legend.neededHeight, _viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                case .bottom:
                    offsetBottom += min(legend.neededHeight, _viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                    
                default:
                    break
                }
            }
            
        case .horizontal:
            switch legend.verticalAlignment
            {
            case .top:
                offsetTop += min(legend.neededHeight, _viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset
                
                // left axis equals the top x-axis in a horizontal chart
                if leftAxis.isEnabled && leftAxis.isDrawLabelsEnabled
                {
                    offsetTop += leftAxis.getRequiredHeightSpace()
                }
                
            case .bottom:
                offsetBottom += min(legend.neededHeight, _viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                // right axis equals the bottom x-axis in a horizontal chart
                if rightAxis.isEnabled && rightAxis.isDrawLabelsEnabled
                {
                    offsetBottom += rightAxis.getRequiredHeightSpace()
                }
            default:
                break
            }
        }
    }
    
    internal override func calculateOffsets()
    {
        var offsetLeft: CGFloat = 0.0,
        offsetRight: CGFloat = 0.0,
        offsetTop: CGFloat = 0.0,
        offsetBottom: CGFloat = 0.0
        
        calculateLegendOffsets(offsetLeft: &offsetLeft,
                               offsetTop: &offsetTop,
                               offsetRight: &offsetRight,
                               offsetBottom: &offsetBottom)
        
        // offsets for y-labels
        if leftAxis.needsOffset
        {
            offsetTop += leftAxis.getRequiredHeightSpace()
        }
        
        if rightAxis.needsOffset
        {
            offsetBottom += rightAxis.getRequiredHeightSpace()
        }
        
        let xlabelwidth = _xAxis.labelRotatedWidth
        
        if _xAxis.isEnabled
        {
            // offsets for x-labels
            if _xAxis.labelPosition == .bottom
            {
                offsetLeft += xlabelwidth
            }
            else if _xAxis.labelPosition == .top
            {
                offsetRight += xlabelwidth
            }
            else if _xAxis.labelPosition == .bothSided
            {
                offsetLeft += xlabelwidth
                offsetRight += xlabelwidth
            }
        }
        
        offsetTop += self.extraTopOffset
        offsetRight += self.extraRightOffset
        offsetBottom += self.extraBottomOffset
        offsetLeft += self.extraLeftOffset

        _viewPortHandler.restrainViewPort(
            offsetLeft: max(self.minOffset, offsetLeft),
            offsetTop: max(self.minOffset, offsetTop),
            offsetRight: max(self.minOffset, offsetRight),
            offsetBottom: max(self.minOffset, offsetBottom))
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    internal override func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: rightAxis._axisMinimum, deltaX: CGFloat(rightAxis.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: leftAxis._axisMinimum, deltaX: CGFloat(leftAxis.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
    }
    
    open override func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawY, y: highlight.drawX)
    }
    
    open override func getBarBounds(entry e: BarChartDataEntry) -> CGRect
    {
        guard
            let data = _data as? BarChartData,
            let set = data.getDataSetForEntry(e) as? IBarChartDataSet
            else { return CGRect.null }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let top = x - 0.5 + barWidth / 2.0
        let bottom = x + 0.5 - barWidth / 2.0
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(forAxis: set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    open override func getPosition(entry e: ChartDataEntry, axis: YAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.y), y: CGFloat(e.x))
        
        getTransformer(forAxis: axis).pointValueToPixel(&vals)
        
        return vals
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.y, y: pt.x)
    }
    
    /// The lowest x-