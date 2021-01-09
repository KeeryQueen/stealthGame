//
//  ChartMarker.swift
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

@objc(IChartMarker)
public protocol IMarker: class
{
    /// - Returns: The desired (general) offset you wish the IMarker to have on the x-axis.
    /// By returning x: -(width / 2) you will center the IMarker horizontally.
    /// By returning y: -(height / 2) you will center the IMarker vertically.
    var offset: CGPoint { get }
    
    /// - Parameters:
    ///   - point: This is the point at which the marker wants to be drawn. You can adjust the offset conditionally based on this argument.
    //