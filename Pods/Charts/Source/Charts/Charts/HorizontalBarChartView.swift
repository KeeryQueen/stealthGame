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
        
 