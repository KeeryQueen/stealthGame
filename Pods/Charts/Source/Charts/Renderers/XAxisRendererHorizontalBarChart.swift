//
//  XAxisRendererHorizontalBarChart.swift
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

open class XAxisRendererHorizontalBarChart: XAxisRenderer
{
    internal weak var chart: BarChartView?
    
    @objc public init(viewPortHandler: ViewPortHandler, xAxis: XAxis?, transformer: Transformer?, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self.chart = chart
    }
    
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer
        {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10 && !viewPortHandler.isFullyZoomedOutY
            {
                let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
                let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
                
                if inverted
                {
                    min = Double(p2.y)
                    max = Double(p1.y)
                }
                else
                {
                    min = Double(p1.y)
                    max = Double(p2.y)
                }
            }
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    open override func computeSize()
    {
        guard let
            xAxis = self.axis as? XAxis
            else { return }
       
        let longest = xAxis.getLongestLabel() as NSString
        
        let labelSize = longest.size(withAttributes: [NSAttributedString.Key.font: xAxis.labelFont])
        
        let labelWidth = floor(labelSize.width + xAxis.xOffset * 3.5)
        let labelHeight = labelSize.height
        let labelRotatedSize = CGSize(width: labelSize.width, height: labelHeight).rotatedBy(degrees: xAxis.labelRotationAngle)

        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = round(labelRotatedSize.width + xAxis.xOffset * 3.5)
        xAxis.labelRotatedHeight = round(labelRotatedSize.height)
    }

    open override func renderAxisLabels(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis
            else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawLabelsEnabled || chart?.data === nil
        {
            return
        }
        
        let xoffset = xAxis.xOffset
        
        if xAxis.labelPosition == .top
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
        }
        else if xAxis.labelPosition == .topInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if xAxis.labelPosition == .bottom
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if xAxis.labelPosition == .bottomInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
    }

    /// draws the x-labels on the specified y-position
    open override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle.DEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in stride(from: 0, to: xAxis.entryCount, by: 1)
        {
            // only fill x values
            
            position.x = 0.0
            
            if centeringEnabled
            {
                position.y = CGFloat(xAxis.centeredEntries[i])
            }
            else
            {
                position.y = CGFloat(xAxis.entries[i])
            }
            
            transformer.pointValueToPixel(&position)
            
            if viewPortHandler.isInBoundsY(position.y)
            {
                if let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis)
                {
                    drawLabel(
                        context: context,
                        formattedLabel: label,
                        x: pos,
                        y: position.y,
                        attributes: [NSAttributedString.Key.font: labelFont, NSAttributedString.Key.foregroundColor: labelTextColor],
                        anchor: anchor,
                        angleRadians: labelRotationAngleRadians)
                }
            }
        }
    }
    
    @objc open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedString.Key : Any],
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        ChartUtils.drawText(
            context: context,
            text