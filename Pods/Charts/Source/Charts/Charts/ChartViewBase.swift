
//
//  ChartViewBase.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
//  Based on https://github.com/PhilJay/MPAndroidChart/commit/c42b880

import Foundation
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@objc
public protocol ChartViewDelegate
{
    /// Called when a value has been selected inside the chart.
    ///
    /// - Parameters:
    ///   - entry: The selected Entry.
    ///   - highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
    @objc optional func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight)
    
    /// Called when a user stops panning between values on the chart
    @objc optional func chartViewDidEndPanning(_ chartView: ChartViewBase)
    
    // Called when nothing has been selected or an "un-select" has been made.
    @objc optional func chartValueNothingSelected(_ chartView: ChartViewBase)
    
    // Callbacks when the chart is scaled / zoomed via pinch zoom gesture.
    @objc optional func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat)
    
    // Callbacks when the chart is moved / translated via drag gesture.
    @objc optional func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)

    // Callbacks when Animator stops animating
    @objc optional func chartView(_ chartView: ChartViewBase, animatorDidStop animator: Animator)
}

open class ChartViewBase: NSUIView, ChartDataProvider, AnimatorDelegate
{
    // MARK: - Properties
    
    /// - Returns: The object representing all x-labels, this method can be used to
    /// acquire the XAxis object and modify it (e.g. change the position of the
    /// labels)
    @objc open var xAxis: XAxis
    {
        return _xAxis
    }
    
    /// The default IValueFormatter that has been determined by the chart considering the provided minimum and maximum values.
    internal var _defaultValueFormatter: IValueFormatter? = DefaultValueFormatter(decimals: 0)
    
    /// object that holds all data that was originally set for the chart, before it was modified or any filtering algorithms had been applied
    internal var _data: ChartData?
    
    /// Flag that indicates if highlighting per tap (touch) is enabled
    private var _highlightPerTapEnabled = true
    
    /// If set to true, chart continues to scroll after touch up
    @objc open var dragDecelerationEnabled = true
    
    /// Deceleration friction coefficient in [0 ; 1] interval, higher values indicate that speed will decrease slowly, for example if it set to 0, it will stop immediately.
    /// 1 is an invalid value, and will be converted to 0.999 automatically.
    private var _dragDecelerationFrictionCoef: CGFloat = 0.9
    
    /// if true, units are drawn next to the values in the chart
    internal var _drawUnitInChart = false
    
    /// The object representing the labels on the x-axis
    internal var _xAxis: XAxis!
    
    /// The `Description` object of the chart.
    /// This should have been called just "description", but
    @objc open var chartDescription: Description?
        
    /// The legend object containing all data associated with the legend
    internal var _legend: Legend!
    
    /// delegate to receive chart events
    @objc open weak var delegate: ChartViewDelegate?
    
    /// text that is displayed when the chart is empty
    @objc open var noDataText = "No chart data available."
    
    /// Font to be used for the no data text.
    @objc open var noDataFont = NSUIFont.systemFont(ofSize: 12)
    
    /// color of the no data text
    @objc open var noDataTextColor: NSUIColor = .labelOrBlack

    /// alignment of the no data text
    @objc open var noDataTextAlignment: NSTextAlignment = .left

    internal var _legendRenderer: LegendRenderer!
    
    /// object responsible for rendering the data
    @objc open var renderer: DataRenderer?
    
    @objc open var highlighter: IHighlighter?
    
    /// object that manages the bounds and drawing constraints of the chart
    internal var _viewPortHandler: ViewPortHandler!
    
    /// object responsible for animations
    internal var _animator: Animator!
    
    /// flag that indicates if offsets calculation has already been done or not
    private var _offsetsCalculated = false
    
    /// array of Highlight objects that reference the highlighted slices in the chart
    internal var _indicesToHighlight = [Highlight]()
    
    /// `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    @objc open var drawMarkers = true
    
    /// - Returns: `true` if drawing the marker is enabled when tapping on values
    /// (use the `marker` property to specify a marker)
    @objc open var isDrawMarkersEnabled: Bool { return drawMarkers }
    
    /// The marker that is displayed when a value is clicked on the chart
    @objc open var marker: IMarker?
    
    private var _interceptTouchEvents = false
    
    /// An extra offset to be appended to the viewport's top
    @objc open var extraTopOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's right
    @objc open var extraRightOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's bottom
    @objc open var extraBottomOffset: CGFloat = 0.0
    
    /// An extra offset to be appended to the viewport's left
    @objc open var extraLeftOffset: CGFloat = 0.0
    
    @objc open func setExtraOffsets(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
    {
        extraLeftOffset = left
        extraTopOffset = top
        extraRightOffset = right
        extraBottomOffset = bottom
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit
    {
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    internal func initialize()
    {
        #if os(iOS)
        self.backgroundColor = NSUIColor.clear
        #endif

        _animator = Animator()
        _animator.delegate = self

        _viewPortHandler = ViewPortHandler(width: bounds.size.width, height: bounds.size.height)
        
        chartDescription = Description()
        
        _legend = Legend()
        _legendRenderer = LegendRenderer(viewPortHandler: _viewPortHandler, legend: _legend)
        
        _xAxis = XAxis()
        
        self.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    // MARK: - ChartViewBase
    
    /// The data for the chart
    open var data: ChartData?
    {
        get
        {
            return _data
        }
        set
        {
            _data = newValue
            _offsetsCalculated = false
            
            guard let _data = _data else
            {
                setNeedsDisplay()
                return
            }
            
            // calculate how many digits are needed
            setupDefaultFormatter(min: _data.getYMin(), max: _data.getYMax())
            
            for set in _data.dataSets
            {
                if set.needsFormatter || set.valueFormatter === _defaultValueFormatter
                {
                    set.valueFormatter = _defaultValueFormatter
                }
            }
            
            // let the chart know there is new data
            notifyDataSetChanged()
        }
    }
    
    /// Clears the chart from all data (sets it to null) and refreshes it (by calling setNeedsDisplay()).
    @objc open func clear()
    {
        _data = nil
        _offsetsCalculated = false
        _indicesToHighlight.removeAll()
        lastHighlighted = nil
    
        setNeedsDisplay()
    }
    
    /// Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to nil. Also refreshes the chart by calling setNeedsDisplay().
    @objc open func clearValues()
    {
        _data?.clearValues()
        setNeedsDisplay()
    }

    /// - Returns: `true` if the chart is empty (meaning it's data object is either null or contains no entries).
    @objc open func isEmpty() -> Bool
    {
        guard let data = _data else { return true }

        if data.entryCount <= 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /// Lets the chart know its underlying data has changed and should perform all necessary recalculations.
    /// It is crucial that this method is called everytime data is changed dynamically. Not calling this method can lead to crashes or unexpected behaviour.
    @objc open func notifyDataSetChanged()
    {
        fatalError("notifyDataSetChanged() cannot be called on ChartViewBase")
    }
    
    /// Calculates the offsets of the chart to the border depending on the position of an eventual legend or depending on the length of the y-axis and x-axis labels and their position
    internal func calculateOffsets()
    {
        fatalError("calculateOffsets() cannot be called on ChartViewBase")
    }
    
    /// calcualtes the y-min and y-max value and the y-delta and x-delta value
    internal func calcMinMax()
    {
        fatalError("calcMinMax() cannot be called on ChartViewBase")
    }
    
    /// calculates the required number of digits for the values that might be drawn in the chart (if enabled), and creates the default value formatter
    internal func setupDefaultFormatter(min: Double, max: Double)
    {
        // check if a custom formatter is set or not
        var reference = Double(0.0)
        
        if let data = _data , data.entryCount >= 2
        {
            reference = fabs(max - min)
        }
        else
        {
            let absMin = fabs(min)
            let absMax = fabs(max)
            reference = absMin > absMax ? absMin : absMax
        }
        
    
        if _defaultValueFormatter is DefaultValueFormatter
        {
            // setup the formatter with a new number of digits
            let digits = reference.decimalPlaces
            
            (_defaultValueFormatter as? DefaultValueFormatter)?.decimals
             = digits
        }
    }
    
    open override func draw(_ rect: CGRect)
    {
        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }
        
        let frame = self.bounds

        if _data === nil && noDataText.count > 0
        {
            context.saveGState()
            defer { context.restoreGState() }

            let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paragraphStyle.minimumLineHeight = noDataFont.lineHeight
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = noDataTextAlignment

            ChartUtils.drawMultilineText(
                context: context,
                text: noDataText,
                point: CGPoint(x: frame.width / 2.0, y: frame.height / 2.0),
                attributes:
                [.font: noDataFont,
                 .foregroundColor: noDataTextColor,
                 .paragraphStyle: paragraphStyle],
                constrainedToSize: self.bounds.size,
                anchor: CGPoint(x: 0.5, y: 0.5),
                angleRadians: 0.0)
            
            return
        }
        
        if !_offsetsCalculated
        {
            calculateOffsets()
            _offsetsCalculated = true
        }
    }
    
    /// Draws the description text in the bottom right corner of the chart (per default)
    internal func drawDescription(context: CGContext)
    {
        // check if description should be drawn
        guard
            let description = chartDescription,
            description.isEnabled,
            let descriptionText = description.text,
            descriptionText.count > 0
            else { return }
        
        let position = description.position ?? CGPoint(x: bounds.width - _viewPortHandler.offsetRight - description.xOffset,
                                                       y: bounds.height - _viewPortHandler.offsetBottom - description.yOffset - description.font.lineHeight)
        
        var attrs = [NSAttributedString.Key : Any]()
        
        attrs[NSAttributedString.Key.font] = description.font
        attrs[NSAttributedString.Key.foregroundColor] = description.textColor

        ChartUtils.drawText(
            context: context,
            text: descriptionText,
            point: position,
            align: description.textAlign,
            attributes: attrs)
    }
    
    // MARK: - Accessibility

    open override func accessibilityChildren() -> [Any]? {
        return renderer?.accessibleChartElements
    }

    // MARK: - Highlighting
    
    /// The array of currently highlighted values. This might an empty if nothing is highlighted.
    @objc open var highlighted: [Highlight]
    {
        return _indicesToHighlight
    }
    
    /// Set this to false to prevent values from being highlighted by tap gesture.
    /// Values can still be highlighted via drag or programmatically.
    /// **default**: true
    @objc open var highlightPerTapEnabled: Bool
    {
        get { return _highlightPerTapEnabled }
        set { _highlightPerTapEnabled = newValue }
    }
    
    /// `true` if values can be highlighted via tap gesture, `false` ifnot.
    @objc open var isHighLightPerTapEnabled: Bool
    {
        return highlightPerTapEnabled
    }
    
    /// Checks if the highlight array is null, has a length of zero or if the first object is null.
    ///
    /// - Returns: `true` if there are values to highlight, `false` ifthere are no values to highlight.
    @objc open func valuesToHighlight() -> Bool
    {
        return !_indicesToHighlight.isEmpty
    }

    /// Highlights the values at the given indices in the given DataSets. Provide
    /// null or an empty array to undo all highlighting. 
    /// This should be used to programmatically highlight values.
    /// This method *will not* call the delegate.
    @objc open func highlightValues(_ highs: [Highlight]?)
    {
        // set the indices to highlight
        _indicesToHighlight = highs ?? [Highlight]()
        
        if _indicesToHighlight.isEmpty
        {
            self.lastHighlighted = nil
        }
        else
        {
            self.lastHighlighted = _indicesToHighlight[0]
        }

        // redraw the chart
        setNeedsDisplay()
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    /// This method will call the delegate.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - y: The y-value to highlight. Supply `NaN` for "any"
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1)
    {
        highlightValue(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: true)
    }
    
    /// Highlights any y-value at the given x-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    ///   - callDelegate: Should the delegate be called for this change
    @objc open func highlightValue(x: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        highlightValue(x: x, y: .nan, dataSetIndex: dataSetIndex, dataIndex: dataIndex, callDelegate: callDelegate)
    }
    
    /// Highlights the value at the given x-value and y-value in the given DataSet.
    /// Provide -1 as the dataSetIndex to undo all highlighting.
    ///
    /// - Parameters:
    ///   - x: The x-value to highlight
    ///   - y: The y-value to highlight. Supply `NaN` for "any"
    ///   - dataSetIndex: The dataset index to search in
    ///   - dataIndex: The data index to search in (only used in CombinedChartView currently)
    ///   - callDelegate: Should the delegate be called for this change
    @objc open func highlightValue(x: Double, y: Double, dataSetIndex: Int, dataIndex: Int = -1, callDelegate: Bool)
    {
        guard let data = _data else
        {
            Swift.print("Value not highlighted because data is nil")
            return
        }
        
        if dataSetIndex < 0 || dataSetIndex >= data.dataSetCount
        {
            highlightValue(nil, callDelegate: callDelegate)
        }
        else
        {
            highlightValue(Highlight(x: x, y: y, dataSetIndex: dataSetIndex, dataIndex: dataIndex), callDelegate: callDelegate)
        }
    }
    
    /// Highlights the values represented by the provided Highlight object
    /// This method *will not* call the delegate.
    ///
    /// - Parameters:
    ///   - highlight: contains information about which entry should be highlighted
    @objc open func highlightValue(_ highlight: Highlight?)
    {
        highlightValue(highlight, callDelegate: false)
    }

    /// Highlights the value selected by touch gesture.
    @objc open func highlightValue(_ highlight: Highlight?, callDelegate: Bool)
    {
        var entry: ChartDataEntry?
        var h = highlight
        
        if h == nil
        {
            self.lastHighlighted = nil
            _indicesToHighlight.removeAll(keepingCapacity: false)
        }
        else
        {
            // set the indices to highlight
            entry = _data?.entryForHighlight(h!)
            if entry == nil
            {
                h = nil
                _indicesToHighlight.removeAll(keepingCapacity: false)
            }
            else
            {
                _indicesToHighlight = [h!]
            }
        }