//
//  BubbleChartRenderer.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class BubbleChartRenderer: BarLineScatterCandleBubbleRenderer
{
    /// A nested array of elements ordered logically (i.e not in visual/drawing order) for use with VoiceOver.
    private lazy var accessibilityOrderedElements: [[NSUIAccessibilityElement]] = accessibilityCreateEmptyOrderedElements()

    @objc open weak var dataProvider: BubbleChartDataProvider?
    
    @objc public init(dataProvider: BubbleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData
            else { return }
        
        // If we redraw the data, remove and repopulate accessible elements to update label values and frames
        accessibleChartElements.removeAll()
        accessibilityOrderedElements = accessibilityCreateEmptyOrderedElements()

        // Make the chart header the first element in the accessible elements array
        if let chart = dataProvider as? BubbleChartView {
            let element = createAccessibleHeader(usingChart: chart,
                                                 andData: bubbleData,
                                                 withDefaultDescription: "Bubble Chart")
            accessibleChartElements.append(element)
        }

        for (i, set) in (bubbleData.dataSets as! [IBubbleChartDataSet]).enumerated() where set.isVisible
        {
            drawDataSet(context: context, dataSet: set, dataSetIndex: i)
        }

        // Merge nested ordered arrays into the single accessibleChartElements.
        accessibleChartElements.append(contentsOf: accessibilityOrderedElements.flatMap { $0 } )
        accessibilityPostLayoutChangedNotification()
    }
    
    private func getShapeSize(
        entrySize: CGFloat,
        maxSize: CGFloat,
        reference: CGFloat,
        normalizeSize: Bool) -> CGFloat
    {
        let factor: CGFloat = normalizeSize
            ? ((maxSize == 0.0) ? 1.0 : sqrt(entrySize / maxSize))
            : entrySize
        let shapeSize: CGFloat = reference * factor
        return shapeSize
    }
    
    private var _pointBuffer = CGPoint()
    private var _sizeBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: IBubbleChartDataSet, dataSetIndex: Int)
  