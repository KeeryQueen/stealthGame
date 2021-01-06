//
//  Description.swift
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

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

@objc(ChartDescription)
open class Description: ComponentBase
{
    public override init()
    {
        #if os(tvOS)
        // 23 is the smallest recommended font size on the TV
        font = .systemFont(ofSize: 23)
        #elseif os(OSX)
        font = .systemFont(ofSize: NSUIFont.systemFontSize)
        #else
        font = .systemFont(ofSize: 8.0)
        #endif
        
        super.init()
  