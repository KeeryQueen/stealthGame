//
//  BarChartRenderer.swift
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

open class BarChartRenderer: BarLineScatterCandleBubbleRenderer
{
    /// A nested array of elements ordered logically (i.e not in visual/drawing order) for use with VoiceOver
    ///
    /// Its use is apparent when there are multiple data sets, since we want to read bars in left to right order,
    /// irrespective of dataset. However, drawing is done per dataset, so using this array and then flattening it prevents us from needing to
    /// re-render for the sake of accessibility.
    ///
    /// In practise, its structure is:
    ///
    /// ````
    ///     [
    ///      [dataset1 element1, dataset2 element1],
    ///      [dataset1 element2, dataset2 element2],
    ///      [dataset1 element3, dataset2 element3]
    ///     ...
    ///     ]
    /// ````
    /// This is done to provide numerical inference across datasets to a screenreader user, in the same way that a sighted individual
    /// uses a multi-dataset bar chart.
    ///
    /// The ````internal```` specifier is to allow subclasses (HorizontalBar) to populate the same array
    internal lazy var accessibilityOrderedElements: [[NSUIAccessibilityElement]] = accessibilityCreateEmptyOrderedElements()

    private class Buffer
    {
        var rects = [CGRect]()
    }
    
    @objc open weak var dataProvider: BarChartDataProvider?
    
    @objc public init(dataProvider: BarChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    // [CGRect] per dataset
    private var _buffers = [Buffer]()
    
    open override func initBuffers()
    {
        if let barData = dataProvider?.barData
        {
            // Matche buffers count to dataset count
            if _buffers.count != barData.dataSetCount
            {
                while _buffers.count < barData.dataSetCount
                {
                    _buffers.append(Buffer())
                }
                while _buffers.count > barData.dataSetCount
                {
                    _buffers.removeLast()
                }
            }
            
            for i in stride(from: 0, to: barData.dataSetCount, by: 1)
            {
                let set = barData.dataSets[i] as! IBarChartDataSet
                let size = set.entryCount * (set.isStacked ? set.stackSize : 1)
                if _buffers[i].rects.count != size
                {
                    _buffers[i].rects = [CGRect](repeating: CGRect(), count: size)
                }
            }
        }
        else
        {
            _buffers.removeAll()
        }
    }
    
    private func prepareBuffer(dataSet: IBarChartDataSet, index: Int)
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }
        
        let barWidthHalf = barData.barWidth / 2.0
    
        let buffer = _buffers[index]
        var bufferIndex = 0
        let containsStacks = dataSet.isStacked
        
        let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        var barRect = CGRect()
        var x: Double
        var y: Double

        
        for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            let vals = e.yValues

            x = e.x
            y = e.y

            if !containsStacks || vals == nil
            {
                let left = CGFloat(x - barWidthHalf)
                let right = CGFloat(x + barWidthHalf)
                var top = isInverted
                    ? (y <= 0.0 ? CGFloat(y) : 0)
                    : (y >= 0.0 ? CGFloat(y) : 0)
                var bottom = isInverted
                    ? (y >= 0.0 ? CGF