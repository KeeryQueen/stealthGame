//
//  BarLineChartViewBase.swift
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

/// Base-class of LineChart, BarChart, ScatterChart and CandleStickChart.
open class BarLineChartViewBase: ChartViewBase, BarLineScatterCandleBubbleChartDataProvider, NSUIGestureRecognizerDelegate
{
    /// the maximum number of entries to which values will be drawn
    /// (entry numbers greater than this value will cause value-labels to disappear)
    internal var _maxVisibleCount = 100
    
    /// flag that indicates if auto scaling on the y axis is enabled
    private var _autoScaleMinMaxEnabled = false
    
    private var _pinchZoomEnabled = false
    private var _doubleTapToZoomEnabled = true
    private var _dragXEnabled = true
    private var _dragYEnabled = true
    
    private var _scaleXEnabled = true
    private var _scaleYEnabled = true
    
    /// the color for the background of the chart-drawing area (everything behind the grid lines).
    @objc open var gridBackgroundColor = NSUIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
    
    @objc open var borderColor = NSUIColor.black
    @objc open var borderLineWidth: CGFloat = 1.0
    
    /// flag indicating if the grid background should be drawn or not
    @objc open var drawGridBackgroundEnabled = false
    
    /// When enabled, the borders rectangle will be rendered.
    /// If this is enabled, there is no point drawing the axis-lines of x- and y-axis.
    @objc open var drawBordersEnabled = false
    
    /// When enabled, the values will be clipped to contentRect, otherwise they can bleed outside the content rect.
    @objc open var clipValuesToContentEnabled: Bool = false

    /// When disabled, the data and/or highlights will not be clipped to contentRect. Disabling this option can
    /// be useful, when the data lies fully within the content rect, but is drawn in such a way (such as thick lines)
    /// that there is unwanted clipping.
    @objc open var clipDataToContentEnabled: Bool = true

    /// Sets the minimum offset (padding) around the chart, defaults to 10
    @objc open var minOffset = CGFloat(10.0)
    
    /// Sets whether the chart should keep its position (zoom / scroll) after a rotation (orientation change)
    /// **default**: false
    @objc open var keepPositionOnRotation: Bool = false
    
    /// The left y-axis object. In the horizontal bar-chart, this is the
    /// top axis.
    @objc open internal(set) var leftAxis = YAxis(position: .left)
    
    /// The right y-axis object. In the horizontal bar-chart, this is the
    /// bottom axis.
    @objc open internal(set) var rightAxis = YAxis(position: .right)

    /// The left Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of YAxisRenderer
    @objc open lazy var leftYAxisRenderer = YAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: leftAxis, transformer: _leftAxisTransformer)

    /// The right Y axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of YAxisRenderer
    @objc open lazy var rightYAxisRenderer = YAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: rightAxis, transformer: _rightAxisTransformer)
    
    internal var _leftAxisTransformer: Transformer!
    internal var _rightAxisTransformer: Transformer!
    
    /// The X axis renderer. This is a read-write property so you can set your own custom renderer here.
    /// **default**: An instance of XAxisRenderer
    @objc open lazy var xAxisRenderer = XAxisRenderer(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer)
    
    internal var _tapGestureRecognizer: NSUITapGestureRecognizer!
    internal var _doubleTapGestureRecognizer: NSUITapGestureRecognizer!
    #if !os(tvOS)
    internal var _pinchGestureRecognizer: NSUIPinchGestureRecognizer!
    #endif
    internal var _panGestureRecognizer: NSUIPanGestureRecognizer!
    
    /// flag that indicates if a custom viewport offset has been set
    private var _customViewPortEnabled = false
    
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

        _leftAxisTransformer = Transformer(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = Transformer(viewPortHandler: _viewPortHandler)
        
        self.highlighter = ChartHighlighter(chart: self)
        
        _tapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized(_:)))
        _doubleTapGestureRecognizer = NSUITapGestureRecognizer(target: self, action: #selector(doubleTapGestureRecognized(_:)))
        _doubleTapGestureRecognizer.nsuiNumberOfTapsRequired = 2
        _panGestureRecognizer = NSUIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        
        _panGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(_tapGestureRecognizer)
        self.addGestureRecognizer(_doubleTapGestureRecognizer)
        self.addGestureRecognizer(_panGestureRecognizer)
        
        _doubleTapGestureRecognizer.isEnabled = _doubleTapToZoomEnabled
        _panGestureRecognizer.isEnabled = _dragXEnabled || _dragYEnabled

        #if !os(tvOS)
        _pinchGestureRecognizer = NSUIPinchGestureRecognizer(target: self, action: #selector(BarLineChartViewBase.pinchGestureRecognized(_:)))
        _pinchGestureRecognizer.delegate = self
        self.addGestureRecognizer(_pinchGestureRecognizer)
        _pinchGestureRecognizer.isEnabled = _pinchZoomEnabled || _scaleXEnabled || _scaleYEnabled
        #endif
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // Saving current position of chart.
        var oldPoint: CGPoint?
        if (keepPositionOnRotation && (keyPath == "frame" || keyPath == "bounds"))
        {
            oldPoint = viewPortHandler.contentRect.origin
            getTransformer(forAxis: .left).pixelToValues(&oldPoint!)
        }
        
        // Superclass transforms chart.
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        // Restoring old position of chart
        if var newPoint = oldPoint , keepPositionOnRotation
        {
            getTransformer(forAxis: .left).pointValueToPixel(&newPoint)
            viewPortHandler.centerViewPort(pt: newPoint, chart: self)
        }
        else
        {
            viewPortHandler.refresh(newMatrix: viewPortHandler.touchMatrix, chart: self, invalidate: true)
        }
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)

        guard data != nil, let renderer = renderer else { return }
        
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }

        // execute all drawing commands
        drawGridBackground(context: context)
        

        if _autoScaleMinMaxEnabled
        {
            autoScale()
        }

        if leftAxis.isEnabled
        {
            leftYAxisRenderer.computeAxis(min: leftAxis._axisMinimum, max: leftAxis._axisMaximum, inverted: leftAxis.isInverted)
        }
        
        if rightAxis.isEnabled
        {
            rightYAxisRenderer.computeAxis(min: rightAxis._axisMinimum, max: rightAxis._axisMaximum, inverted: rightAxis.isInverted)
        }
        
        if _xAxis.isEnabled
        {
            xAxisRenderer.computeAxis(min: _xAxis._axisMinimum, max: _xAxis._axisMaximum, inverted: false)
        }
        
        xAxisRenderer.renderAxisLine(context: context)
        leftYAxisRenderer.renderAxisLine(context: context)
        rightYAxisRenderer.renderAxisLine(context: context)

        // The renderers are responsible for clipping, to account for line-width center etc.
        if xAxis.drawGridLinesBehindDataEnabled
        {
            xAxisRenderer.renderGridLines(context: context)
            leftYAxisRenderer.renderGridLines(context: context)
            rightYAxisRenderer.renderGridLines(context: context)
        }
        
        if _xAxis.isEnabled && _xAxis.isDrawLimitLinesBehindDataEnabled
        {
            xAxisRenderer.renderLimitLines(context: context)
        }
        
        if leftAxis.isEnabled && leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            leftYAxisRenderer.renderLimitLines(context: context)
        }
        
        if rightAxis.isEnabled && rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            rightYAxisRenderer.renderLimitLines(context: context)
        }
        
        context.saveGState()
        // make sure the data cannot be drawn outside the content-rect
        if clipDataToContentEnabled {
            context.clip(to: _viewPortHandler.contentRect)
        }
        renderer.drawData(context: context)
        
        // The renderers are responsible for clipping, to account for line-width center etc.
        if !xAxis.drawGridLinesBehindDataEnabled
        {
            xAxisRenderer.renderGridLines(context: context)
            leftYAxisRenderer.renderGridLines(context: context)
            rightYAxisRenderer.renderGridLines(context: context)
        }
        
        // if highlighting is enabled
        if (valuesToHighlight())
        {
            renderer.drawHighlighted(context: context, indices: _indicesToHighlight)
        }
        
        context.restoreGState()
        
        renderer.drawExtras(context: context)
        
        if _xAxis.isEnabled && !_xAxis.isDrawLimitLinesBehindDataEnabled
        {
            xAxisRenderer.renderLimitLines(context: context)
        }
        
        if leftAxis.isEnabled && !leftAxis.isDrawLimitLinesBehindDataEnabled
        {
            leftYAxisRenderer.renderLimitLines(context: context)
        }
        
        if rightAxis.isEnabled && !rightAxis.isDrawLimitLinesBehindDataEnabled
        {
            rightYAxisRenderer.renderLimitLines(context: context)
        }
        
        xAxisRenderer.renderAxisLabels(context: context)
        leftYAxisRenderer.renderAxisLabels(context: context)
        rightYAxisRenderer.renderAxisLabels(context: context)

        if clipValuesToContentEnabled
        {
            context.saveGState()
            context.clip(to: _viewPortHandler.contentRect)
            
            renderer.drawValues(context: context)
            
            context.restoreGState()
        }
        else
        {
            renderer.drawValues(context: context)
        }

        _legendRenderer.renderLegend(context: context)

        drawDescription(context: context)
        
        drawMarkers(context: context)
    }
    
    private var _autoScaleLastLowestVisibleX: Double?
    private var _autoScaleLastHighestVisibleX: Double?
    
    /// Performs auto scaling of the axis by recalculating the minimum and maximum y-values based on the entries currently in view.
    internal func autoScale()
    {
        guard let data = _data
            else { return }
        
        data.calcMinMaxY(fromX: self.lowestVisibleX, toX: self.highestVisibleX)
        
        _xAxis.calculate(min: data.xMin, max: data.xMax)
        
        // calculate axis range (min / max) according to provided data
        
        if leftAxis.isEnabled
        {
            leftAxis.calculate(min: data.getYMin(axis: .left), max: data.getYMax(axis: .left))
        }
        
        if rightAxis.isEnabled
        {
            rightAxis.calculate(min: data.getYMin(axis: .right), max: data.getYMax(axis: .right))
        }
        
        calculateOffsets()
    }
    
    internal func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(rightAxis.axisRange), chartYMin: rightAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: xAxis._axisMinimum, deltaX: CGFloat(xAxis.axisRange), deltaY: CGFloat(leftAxis.axisRange), chartYMin: leftAxis._axisMinimum)
    }
    
    internal func prepareOffsetMatrix()
    {
        _rightAxisTransformer.prepareMatrixOffset(inverted: rightAxis.isInverted)
        _leftAxisTransformer.prepareMatrixOffset(inverted: leftAxis.isInverted)
    }
    
    open override func notifyDataSetChanged()
    {
        renderer?.initBuffers()
        
        calcMinMax()
        
        leftYAxisRenderer.computeAxis(min: leftAxis._axisMinimum, max: leftAxis._axisMaximum, inverted: leftAxis.isInverted)
        rightYAxisRenderer.computeAxis(min: rightAxis._axisMinimum, max: rightAxis._axisMaximum, inverted: rightAxis.isInverted)
        
        if let data = _data
        {
            xAxisRenderer.computeAxis(
                min: _xAxis._axisMinimum,
                max: _xAxis._axisMaximum,
                inverted: false)

            if _legend !== nil
            {
                legendRenderer?.computeLegend(data: data)
            }
        }
        
        calculateOffsets()
        
        setNeedsDisplay()
    }
    
    internal override func calcMinMax()
    {
        // calculate / set x-axis range
        _xAxis.calculate(min: _data?.xMin ?? 0.0, max: _data?.xMax ?? 0.0)
        
        // calculate axis range (min / max) according to provided data
        leftAxis.calculate(min: _data?.getYMin(axis: .left) ?? 0.0, max: _data?.getYMax(axis: .left) ?? 0.0)
        rightAxis.calculate(min: _data?.getYMin(axis: .right) ?? 0.0, max: _data?.getYMax(axis: .right) ?? 0.0)
    }
    
    internal func calculateLegendOffsets(offsetLeft: inout CGFloat, offsetTop: inout CGFloat, offsetRight: inout CGFloat, offsetBottom: inout CGFloat)
    {
        // setup offsets for legend
        if _legend !== nil && _legend.isEnabled && !_legend.drawInside
        {
            switch _legend.orientation
            {
            case .vertical:
                
                switch _legend.horizontalAlignment
                {
                case .left:
                    offsetLeft += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset
                    
                case .right:
                    offsetRight += min(_legend.neededWidth, _viewPortHandler.chartWidth * _legend.maxSizePercent) + _legend.xOffset
                    
                case .center:
                    
                    switch _legend.verticalAlignment
                    {
                    case .top:
                        offsetTop += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                        
                    case .bottom:
                        offsetBottom += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                        
                    default:
                        break
                    }
                }
                
            case .horizontal:
                
                switch _legend.verticalAlignment
                {
                case .top:
                    offsetTop += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                    
                case .bottom:
                    offsetBottom += min(_legend.neededHeight, _viewPortHandler.chartHeight * _legend.maxSizePercent) + _legend.yOffset
                    
                default:
                    break
                }
            }
        }
    }
    
    internal override func calculateOffsets()
    {
        if !_customViewPortEnabled
        {
            var offsetLeft = CGFloat(0.0)
            var offsetRight = CGFloat(0.0)
            var offsetTop = CGFloat(0.0)
            var offsetBottom = CGFloat(0.0)
            
            calculateLegendOffsets(offsetLeft: &offsetLeft,
                                   offsetTop: &offsetTop,
                                   offsetRight: &offsetRight,
                                   offsetBottom: &offsetBottom)
            
            // offsets for y-labels
            if leftAxis.needsOffset
            {
                offsetLeft += leftAxis.requiredSize().width
            }
            
            if rightAxis.needsOffset
            {
                offsetRight += rightAxis.requiredSize().width
            }

            if xAxis.isEnabled && xAxis.isDrawLabelsEnabled
            {
                let xlabelheight = xAxis.labelRotatedHeight + xAxis.yOffset
                
                // offsets for x-labels
                if xAxis.labelPosition == .bottom
                {
                    offsetBottom += xlabelheight
                }
                else if xAxis.labelPosition == .top
                {
                    offsetTop += xlabelheight
                }
                else if xAxis.labelPosition == .bothSided
                {
                    offsetBottom += xlabelheight
                    offsetTop += xlabelheight
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
        }
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    /// draws the grid background
    internal func drawGridBackground(context: CGContext)
    {
        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.saveGState()
        }
        
        if drawGridBackgroundEnabled
        {
            // draw the grid background
            context.setFillColor(gridBackgroundColor.cgColor)
            context.fill(_viewPortHandler.contentRect)
        }
        
        if drawBordersEnabled
        {
            context.setLineWidth(borderLineWidth)
            context.setStrokeColor(borderColor.cgColor)
            context.stroke(_viewPortHandler.contentRect)
        }
        
        if drawGridBackgroundEnabled || drawBordersEnabled
        {
            context.restoreGState()
        }
    }
    
    // MARK: - Gestures
    
    private enum GestureScaleAxis
    {
        case both
        case x
        case y
    }
    
    private var _isDragging = false
    private var _isScaling = false
    private var _gestureScaleAxis = GestureScaleAxis.both
    private var _closestDataSetToTouch: IChartDataSet!
    private var _panGestureReachedEdge: Bool = false
    private weak var _outerScrollView: NSUIScrollView?
    
    private var _lastPanPoint = CGPoint() /// This is to prevent using setTranslation which resets velocity
    
    private var _decelerationLastTime: TimeInterval = 0.0
    private var _decelerationDisplayLink: NSUIDisplayLink!
    private var _decelerationVelocity = CGPoint()
    
    @objc private func tapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        if _data === nil
        {
            return
        }
        
        if recognizer.state == NSUIGestureRecognizerState.ended
        {
            if !isHighLightPerTapEnabled { return }
            
            let h = getHighlightByTouchPoint(recognizer.location(in: self))
            
            if h === nil || h == self.lastHighlighted
            {
                lastHighlighted = nil
                highlightValue(nil, callDelegate: true)
            }
            else
            {
                lastHighlighted = h
                highlightValue(h, callDelegate: true)
            }
        }
    }
    
    @objc private func doubleTapGestureRecognized(_ recognizer: NSUITapGestureRecognizer)
    {
        if _data === nil
        {
            return
        }
        
        if recognizer.state == NSUIGestureRecognizerState.ended
        {
            if _data !== nil && _doubleTapToZoomEnabled && (data?.entryCount ?? 0) > 0
            {
                var location = recognizer.location(in: self)
                location.x = location.x - _viewPortHandler.offsetLeft
                
                if isTouchInverted()
                {
                    location.y = -(location.y - _viewPortHandler.offsetTop)
                }
                else
                {
                    location.y = -(self.bounds.size.height - location.y - _viewPortHandler.offsetBottom)
                }

                let scaleX: CGFloat = isScaleXEnabled ? 1.4 : 1.0
                let scaleY: CGFloat = isScaleYEnabled ? 1.4 : 1.0

                self.zoom(scaleX: scaleX, scaleY: scaleY, x: location.x, y: location.y)
                delegate?.chartScaled?(self, scaleX: scaleX, scaleY: scaleY)
            }
        }
    }
 