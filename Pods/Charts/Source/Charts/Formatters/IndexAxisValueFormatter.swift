//
//  IndexAxisValueFormatter.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// This formatter is used for passing an array of x-axis labels, on whole x steps.
@objc(ChartIndexAxisValueFormatter)
open class IndexAxisValueFormatter: NSObject, IAxisValueFormatter
{
    private var _values: [String] = [String]()
    private var _valueCount: Int = 0
    
    @objc public var values: [String]
    {
        get
        {
            return _values
        }
        set
        {
            _values = new