//
//  CombinedChartRenderer.swift
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

open class CombinedChartRenderer: DataRenderer
{
    @objc open weak var chart: CombinedChartView?
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    @objc open var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    @objc open var drawBarShadowEnabled = false
    
    internal var _renderers = [DataRenderer]()
    
    internal var _drawOrder: [CombinedChartView.DrawOrder] = [.bar, .bubble, .line, .candle, .scatter]
    
    @objc public init(chart: CombinedChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
        
        createRenderers()
    }
    
    /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into consideration.
    internal func createRenderers()
    {
        _renderers = [DataRenderer]()
        
        guard let chart = chart else { return }

        for order in drawOrder
        {
            switch (order)
            {
            case .bar:
                if chart.barData !== nil
                {
                    _renderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .line:
                if chart.lineData !== nil
                {
                    _renderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .candle:
                if chart.candleData !== nil
                {
                    _renderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .scatter:
                if chart.scatterData !== nil
                {
                    _renderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .bubble:
                if chart.bubbleData !== nil
                {
                    _renderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
            }
        }

    }
    
    open override func initBuffers()
    {
        _renderers.forEach { $0.initBuffers() }
    }
    
    open override func drawData(context: CGContext)
    {
        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()

        if
            let combinedChart = chart,
            let data = combinedChart.data {
            // Make the chart header the first element in the accessible elements array
            let element = createAccessibleHeader(usingChart: combinedChart,
                                                 andData: data,
                                                 withDefaultDescription: "Combined Chart")
            accessibleChartElements.append(element)
        }

        // TODO: Due to the potential complexity of data presented in Combined charts, a more usable way
        // for VO accessibility would be to use axis based traversal rather than by dataset.
        // Hence, accessibleChartElements is not populated below. (Individual renderers guard against dataSource b