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
        let path = CGMutable