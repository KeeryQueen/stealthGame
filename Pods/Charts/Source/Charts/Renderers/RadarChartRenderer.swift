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
      