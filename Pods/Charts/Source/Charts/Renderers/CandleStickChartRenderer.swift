
//
//  CandleStickChartRenderer.swift
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

open class CandleStickChartRenderer: LineScatterCandleRadarRenderer
{
    @objc open weak var dataProvider: CandleChartDataProvider?
    
    @objc public init(dataProvider: CandleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider, let candleData = dataProvider.candleData else { return }

        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()

        // Make the chart header the first element in the accessible elements array
        if let chart = dataProvider as? CandleStickChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: candleData,
                                                 withDefaultDescription: "CandleStick Chart")
            accessibleChartElements.append(element)
        }

        for set in candleData.dataSets as! [ICandleChartDataSet] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    private var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 4)
    private var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _openPoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _closePoints = [CGPoint](repeating: CGPoint(), count: 2)
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: ICandleChartDataSet)
    {
        guard
            let dataProvider = dataProvider
            else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        
        context.setLineWidth(dataSet.shadowWidth)

        for j in _xBounds
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            let xPos = e.x
            
            let open = e.open
            let close = e.close
            let high = e.high
            let low = e.low
            
            let doesContainMultipleDataSets = (dataProvider.candleData?.dataSets.count ?? 1) > 1
            var accessibilityMovementDescription = "neutral"
            var accessibilityRect = CGRect(x: CGFloat(xPos) + 0.5 - barSpace,
                                           y: CGFloat(low * phaseY),
                                           width: (2 * barSpace) - 1.0,
                                           height: (CGFloat(abs(high - low) * phaseY)))
            trans.rectValueToPixel(&accessibilityRect)

            if showCandleBar
            {
                // calculate the shadow
                
                _shadowPoints[0].x = CGFloat(xPos)
                _shadowPoints[1].x = CGFloat(xPos)
                _shadowPoints[2].x = CGFloat(xPos)
                _shadowPoints[3].x = CGFloat(xPos)
                
                if open > close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(close * phaseY)
                }
                else if open < close
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(close * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = CGFloat(open * phaseY)
                }
                else
                {
                    _shadowPoints[0].y = CGFloat(high * phaseY)
                    _shadowPoints[1].y = CGFloat(open * phaseY)
                    _shadowPoints[2].y = CGFloat(low * phaseY)
                    _shadowPoints[3].y = _shadowPoints[1].y
                }
                
                trans.pointValuesToPixel(&_shadowPoints)
                
                // draw the shadows
                
                var shadowColor: NSUIColor! = nil
                if dataSet.shadowColorSameAsCandle
                {
                    if open > close
                    {
                        shadowColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    }
                    else if open < close
                    {
                        shadowColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    }
                    else
                    {
                        shadowColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    }
                }
                
                if shadowColor === nil
                {
                    shadowColor = dataSet.shadowColor ?? dataSet.color(atIndex: j)
                }
                