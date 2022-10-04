//
//  RadarChartRenderer.swift
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

open class RadarChartRenderer: LineRadarRenderer
{
    private lazy var accessibilityXLabels: [String] = {
        guard let chart = chart else { return [] }
        guard let formatter = chart.xAxis.valueFormatter else { return [] }

        let maxEntryCount = chart.data?.maxEntryCountSet?.entryCount ?? 0
        return stride(from: 0, to: maxEntryCount, by: 1).map {
            formatter.stringForValue(Double($0), axis: chart.xAxis)
        }
    }()

    @objc open weak var chart: RadarChartView?

    @objc public init(chart: RadarChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
    }
    
    open override func drawData(context: CGContext)
    {
        guard let chart = chart else { return }
        
        let radarData = chart.data
        
        if radarData != nil
        {
            let mostEntries = radarData?.maxEntryCountSet?.entryCount ?? 0

            // If we redraw the data, remove and repopulate accessible elements to update label values and frames
            self.accessibleChartElements.removeAll()

            // Make the chart header the first element in the accessible elements array
            if let accessibilityHeaderData = radarData as? RadarChartData {
                let element = createAccessibleHeader(usingChart: chart,
                                                     andData: accessibilityHeaderData,
                                                     withDefaultDescription: "Radar Chart")
                self.accessibleChartElements.append(element)
            }

            for set in radarData!.dataSets as! [IRadarChartDataSet] where set.isVisible
            {
                drawDataSet(context: context, dataSet: set, mostEntries: mostEntries)
            }
        }
    }
    
    /// Draws the RadarDataSet
    ///
    /// - Parameters:
    ///   - context:
    ///   - dataSet:
    ///   - mostEntries: the entry count of the dataset with the most entries
    internal func drawDataSet(context: CGContext, dataSet: IRadarChartDataSet, mostEntries: Int)
    {
        guard let chart = chart else { return }
        
        context.saveGState()
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        let entryCount = dataSet.entryCount
        let path = CGMutablePath()
        var hasMovedToPoint = false

        let prefix: String = chart.data?.accessibilityEntryLabelPrefix ?? "Item"
        let description = dataSet.label ?? ""

        // Make a tuple of (xLabels, value, originalIndex) then sort it
        // This is done, so that the labels are narrated in decreasing order of their corresponding value
        // Otherwise, there is no non-visual logic to the data presented
        let accessibilityEntryValues =  Array(0 ..< entryCount).map { (dataSet.entryForIndex($0)?.y ?? 0, $0) }
        let accessibilityAxisLabelValueTuples = zip(accessibilityXLabels, accessibilityEntryValues).map { ($0, $1.0, $1.1) }.sorted { $0.1 > $1.1 }
        let accessibilityDataSetDescription: String = description + ". \(entryCount) \(prefix + (entryCount == 1 ? "" : "s")). "
        let accessibilityFrameWidth: CGFloat = 22.0 // To allow a tap target of 44x44

        var accessibilityEntryElements: [NSUIAccessibilityElement] = []

        for j in 0 ..< entryCount
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            let p = center.moving(distance: CGFloat((e.y - chart.chartYMin) * Double(factor) * phaseY),
                                  atAngle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
            
            if p.x.isNaN
            {
                continue
            }
            
            if !hasMovedToPoint
            {
                path.move(to: p)
                hasMovedToPoint = true
            }
            else
            {
                path.addLine(to: p)
            }

            let accessibilityLabel = accessibilityAxisLabelValueTuples[j].0
            let accessibilityValue = accessibilityAxisLabelValueTuples[j].1
            let accessibilityValueIndex = accessibilityAxisLabelValueTuples[j].2

            let axp = center.moving(distance: CGFloat((accessibilityValue - chart.chartYMin) * Double(factor) * phaseY),
                                    atAngle: sliceangle * CGFloat(accessibilityValueIndex) * CGFloat(phaseX) + chart.rotationAngle)

            let axDescription = description + " - " + accessibilityLabel + ": \(accessibilityValue) \(chart.data?.accessibilityEntryLabelSuffix ?? "")"
            let axElement = createAccessibleElement(withDescription: axDescription,
                                                    container: chart,
                                                    dataSet: dataSet)
            { (element) in
                element.accessibilityFrame = CGRect(x: axp.x - accessibilityFrameWidth,
                                                    y: axp.y - accessibilityFrameWidth,
                                                    width: 2 * accessibilityFrameWidth,
                                                    height: 2 * accessibilityFrameWidth)
            }

            accessibilityEntryElements.append(axElement)
        }
        
        // if this is the largest set, close it
        if