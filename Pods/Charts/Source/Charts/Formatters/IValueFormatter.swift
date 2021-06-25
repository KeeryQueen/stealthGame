//
//  IValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Interface that allows custom formatting of all values inside the chart before they are drawn to the screen.
///
/// Simply create your own formatting class and let it implement ValueFormatter. Then override the stringForValue()
/// method and return whatever you want.

@objc(IChartValueFormatter)
public protocol IValueFormatter: class
{
    
    /// Called when a value (from labels inside the chart) is formatted before being dr