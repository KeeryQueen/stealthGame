//
//  ViewPortJob.swift
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

// This defines a viewport modification job, used for delaying or animating viewport changes
@objc(ChartViewPortJob)
open class ViewPortJob: NSObject
{
    internal var point: CGPoint = CGPoint()
    internal weak var viewPortHandler: ViewPortHandler?
    internal var xValue: Double = 0.0
    internal var yValue: Double = 0.0
    internal weak var 