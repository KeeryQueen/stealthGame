//
//  TransformerHorizontalBarChart.swift
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

@objc(ChartTransformerHorizontalBarChart)
open class TransformerHorizontalBarChart: Transformer
{
    /// Prepares the matrix that contains all offsets.
    open override func prepareMatrixOffset(inverted: Bool)
  