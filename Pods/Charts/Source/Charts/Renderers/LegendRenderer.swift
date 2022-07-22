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
 