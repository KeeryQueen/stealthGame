
//
//  PieChartView.swift
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

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

/// View that represents a pie chart. Draws cake like slices.
open class PieChartView: PieRadarChartViewBase
{
    /// rect object that represents the bounds of the piechart, needed for drawing the circle
    private var _circleBox = CGRect()
    
    /// flag indicating if entry labels should be drawn or not
    private var _drawEntryLabelsEnabled = true
    
    /// array that holds the width of each pie-slice in degrees
    private var _drawAngles = [CGFloat]()
    
    /// array that holds the absolute angle in degrees of each slice
    private var _absoluteAngles = [CGFloat]()
    
    /// if true, the hole inside the chart will be drawn
    private var _drawHoleEnabled = true
    
    private var _holeColor: NSUIColor? = NSUIColor.white
    
    /// Sets the color the entry labels are drawn with.
    private var _entryLabelColor: NSUIColor? = NSUIColor.white
    
    /// Sets the font the entry labels are drawn with.
    private var _entryLabelFont: NSUIFont? = NSUIFont(name: "HelveticaNeue", size: 13.0)
    
    /// if true, the hole will see-through to the inner tips of the slices
    private var _drawSlicesUnderHoleEnabled = false
    
    /// if true, the values inside the piechart are drawn as percent values
    private var _usePercentValuesEnabled = false
    
    /// variable for the text that is drawn in the center of the pie-chart
    private var _centerAttributedText: NSAttributedString?
    
    /// the offset on the x- and y-axis the center text has in dp.
    private var _centerTextOffset: CGPoint = CGPoint()
    
    /// indicates the size of the hole in the center of the piechart
    ///
    /// **default**: `0.5`
    private var _holeRadiusPercent = CGFloat(0.5)
    
    private var _transparentCircleColor: NSUIColor? = NSUIColor(white: 1.0, alpha: 105.0/255.0)
    
    /// the radius of the transparent circle next to the chart-hole in the center
    private var _transparentCircleRadiusPercent = CGFloat(0.55)
    
    /// if enabled, centertext is drawn
    private var _drawCenterTextEnabled = true
    
    private var _centerTextRadiusPercent: CGFloat = 1.0
    
    /// maximum angle for this pie
    private var _maxAngle: CGFloat = 360.0

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
        
        renderer = PieChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxis = nil
        
        self.highlighter = PieHighlighter(chart: self)
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if _data === nil
        {
            return
        }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext, let renderer = renderer else
        {
            return
        }
        
        renderer.drawData(context: context)
        
        if (valuesToHighlight())
        {
            renderer.drawHighlighted(context: context, indices: _indicesToHighlight)
        }
        
        renderer.drawExtras(context: context)
        
        renderer.drawValues(context: context)
        
        legendRenderer.renderLegend(context: context)
        
        drawDescription(context: context)
        
        drawMarkers(context: context)
    }

    /// if width is larger than height
    private var widthLarger: Bool
    {
        return _viewPortHandler.contentRect.orientation == .landscape
    }

    /// adjusted radius. Use diameter when it's half pie and width is larger
    private var adjustedRadius: CGFloat
    {
        return maxAngle <= 180 && widthLarger ? diameter : diameter / 2.0
    }

    /// true centerOffsets considering half pie & width is larger
    private func adjustedCenterOffsets() -> CGPoint
    {
        var c = self.centerOffsets
        c.y = maxAngle <= 180 && widthLarger ? c.y + adjustedRadius / 2 : c.y
        return c
    }
    
    internal override func calculateOffsets()
    {
        super.calculateOffsets()
        
        // prevent nullpointer when no data set
        if _data === nil
        {
            return
        }

        let radius = adjustedRadius
        
        let c = adjustedCenterOffsets()
        
        let shift = (data as? PieChartData)?.dataSet?.selectionShift ?? 0.0
        
        // create the circle box that will contain the pie-chart (the bounds of the pie-chart)
        _circleBox.origin.x = (c.x - radius) + shift
        _circleBox.origin.y = (c.y - radius) + shift
        _circleBox.size.width = radius * 2 - shift * 2.0
        _circleBox.size.height = radius * 2 - shift * 2.0

    }

    internal override func calcMinMax()
    {
        calcAngles()
    }

    @objc open override func angleForPoint(x: CGFloat, y: CGFloat) -> CGFloat
    {
        let c = adjustedCenterOffsets()

        let tx = Double(x - c.x)
        let ty = Double(y - c.y)
        let length = sqrt(tx * tx + ty * ty)
        let r = acos(ty / length)

        var angle = r.RAD2DEG

        if x > c.x
        {
            angle = 360.0 - angle
        }

        // add 90° because chart starts EAST
        angle = angle + 90.0

        // neutralize overflow
        if angle > 360.0
        {
            angle = angle - 360.0
        }

        return CGFloat(angle)
    }

    /// - Returns: The distance of a certain point on the chart to the center of the chart.
    @objc open override func distanceToCenter(x: CGFloat, y: CGFloat) -> CGFloat
    {
        let c = adjustedCenterOffsets()

        var dist = CGFloat(0.0)

        var xDist = CGFloat(0.0)
        var yDist = CGFloat(0.0)

        if x > c.x
        {
            xDist = x - c.x
        }
        else
        {
            xDist = c.x - x
        }

        if y > c.y
        {
            yDist = y - c.y
        }
        else
        {
            yDist = c.y - y
        }

        // pythagoras
        dist = sqrt(pow(xDist, 2.0) + pow(yDist, 2.0))

        return dist
    }

    open override func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        let center = self.centerCircleBox
        var r = self.radius
        
        var off = r / 10.0 * 3.6
        
        if self.isDrawHoleEnabled
        {
            off = (r - (r * self.holeRadiusPercent)) / 2.0
        }
        
        r -= off // offset to keep things inside the chart
        
        let rotationAngle = self.rotationAngle
        
        let entryIndex = Int(highlight.x)
        
        // offset needed to center the drawn text in the slice
        let offset = drawAngles[entryIndex] / 2.0
        
        // calculate the text position
        let x: CGFloat = (r * cos(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.x)
        let y: CGFloat = (r * sin(((rotationAngle + absoluteAngles[entryIndex] - offset) * CGFloat(_animator.phaseY)).DEG2RAD) + center.y)
        
        return CGPoint(x: x, y: y)
    }
    
    /// calculates the needed angles for the chart slices
    private func calcAngles()
    {
        _drawAngles = [CGFloat]()
        _absoluteAngles = [CGFloat]()
        
        guard let data = _data else { return }

        let entryCount = data.entryCount
        
        _drawAngles.reserveCapacity(entryCount)
        _absoluteAngles.reserveCapacity(entryCount)
        
        let yValueSum = (_data as! PieChartData).yValueSum

        var cnt = 0

        for set in data.dataSets
        {
            for j in 0 ..< set.entryCount
            {
                guard let e = set.entryForIndex(j) else { continue }
                
                _drawAngles.append(calcAngle(value: abs(e.y), yValueSum: yValueSum))

                if cnt == 0
                {
                    _absoluteAngles.append(_drawAngles[cnt])
                }
                else
                {
                    _absoluteAngles.append(_absoluteAngles[cnt - 1] + _drawAngles[cnt])
                }

                cnt += 1
            }
        }
    }
    
    /// Checks if the given index is set to be highlighted.
    @objc open func needsHighlight(index: Int) -> Bool
    {
        return _indicesToHighlight.contains { Int($0.x) == index }
    }
    
    /// calculates the needed angle for a given value
    private func calcAngle(_ value: Double) -> CGFloat
    {