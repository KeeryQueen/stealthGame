//
//  IPieChartDataSet.swift
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

@objc
public protocol IPieChartDataSet: IChartDataSet
{
    // MARK: - Styling functions and accessors

    /// the space in pixels between the pie-slices
    /// **default**: 0
    /// **maximum**: 20
    var sliceSpace: CG