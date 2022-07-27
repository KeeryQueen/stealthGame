//
//  LegendRenderer.swift
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

@objc(ChartLegendRenderer)
open class LegendRenderer: Renderer
{
    /// the legend object this renderer renders
    @objc open var legend: Legend?

    @objc public init(viewPortHandler: ViewPortHandler, legend: Legend?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.legend = legend
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    @objc open func computeLegend(data: ChartData)
    {
        guard let legend = legend else { return }
        
        if !legend.isLegendCustom
        {
            var entries: [LegendEntry] = []
            
            // loop for building up the colors and labels used in the legend
            for i in 0..<data.dataSetCount
            {
                guard let dataSet = data.getDataSetByIndex(i) else { continue }
                
                let clrs: [NSUIColor] = dataSet.colors
                let entryCount = dataSet.entryCount
                
                // if we have a barchart with stacked bars
                if dataSet is IBarChartDataSet &&
                    (dataSet as! IBarChartDataSet).isStacked
                {
                    let bds = dataSet as! IBarChartDataSet
                    let sLabels = bds.stackLabels
                    let minEntries = min(clrs.count, bds.stackSize)

                    for j in 0..<minEntries
                    {
                        let label: String?
                        if (sLabels.count > 0)
                        {
                            let labelIndex = j % minEntries
                            label = sLabels.indices.contains(labelIndex) ? sLabels[labelIndex] : nil
                        }
                        else
                        {
                            label = nil
                        }

                        entries.append(
                            LegendEntry(
                                label: label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                    
                    if dataSet.label != nil
                    {
                        // add the legend description label
                        
                        entries.append(
                            LegendEntry(
                                label: dataSet.label,
                                form: .none,
                                formSize: CGFloat.nan,
                                formLineWidth: CGFloat.nan,
                       