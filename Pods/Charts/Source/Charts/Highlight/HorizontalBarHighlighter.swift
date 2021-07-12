//
//  HorizontalBarHighlighter.swift
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

@objc(HorizontalBarChartHighlighter)
open class HorizontalBarHighlighter: BarHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let barData