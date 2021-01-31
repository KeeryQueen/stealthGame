//
//  Legend.swift
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

@objc(ChartLegend)
open class Legend: ComponentBase
{
    @objc(ChartLegendForm)
    public enum Form: Int
    {
        /// Avoid drawing a form
        case none
        
        /// Do not draw the a form, but leave space for it
        case empty
        
        /// Use default (default dataset's form to the legend's form)
        case `default`
        
        /// Draw a square
        case square
        
        /// Draw a circle
        case circle
        
        /// Draw a horizontal line
        case line
    }
    
    @objc(ChartLegendHorizontalAlignment)
    public enum HorizontalAlignment: Int
    {
        case left
        case center
        case right
    }
    
    @objc(ChartLegendVerticalAlignment)
    public enum VerticalAlignment: Int
    {
        case top
        case center
        case bottom
    }
    
    @objc(ChartLegendOrientation)
    public enum Orientation: Int
    {
        case horizontal
        case vertical
    }
    
    @objc(ChartLegendDirection)
    public enum Direction: Int
    {
        case leftToRight
        case rightToLeft
    }
    
    /// The legend entries array
    @objc open var entries = [LegendEntry]()
    
    /// Entries that will be appended to the end of the auto calculated entries after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    @objc open var extraEntries = [LegendEntry]()
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    private var _isLegendCustom = false

    /// The horizontal alignment of the legend
    @objc open var horizontalAlignment: HorizontalAlignment = HorizontalAlignment.left
    
    /// The vertical alignment of the legend
    @objc open var verticalAlignment: VerticalAlignment = VerticalAlignment.bottom
    
    /// The orientation of the legend
    @objc open var orientation: Orientation = Orientation.horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    @objc open var drawInside: Bool = false
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    @objc open var isDrawInsideEnabled: Bool { return drawInside }
    
    /// The text direction of the legend
    @objc open var direction: Direction = Direction.leftToRight

    @objc open var font: NSUIFont = NSUIFont.systemFont(ofSize: 10.0)
    @objc open var textColor = NSUIColor.labelOrBlack

    /// The form/shape of the legend forms
    @objc open var form = Form.square
    
    /// The size of the legend forms
    @objc open var formSize = CGFloat(8.0)
    
    /// The line width for forms that consist of lines
    @objc open var formLineWidth = CGFloat(3.0)
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    @objc open var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    @objc open var formLineDashLengths: [CGFloat]?
    
    @objc open var xEntrySpace = CGFloat(6.0)
    @objc open var yEntrySpace = CGFloat(0.0)
    @objc open var formToTextSpace = CGFloat(5.0)
    @objc open var stackSpace = CGFloat(3.0)
    
    @objc open var calculatedLabelSizes = [CGSize]()
    @objc open var calculatedLabelBreakPoints = [Bool]()
    @objc open var calculatedLineSizes = [CGSize]()
    
    public override init()
    {
        super.init()
        
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    @objc public init(entries: [LegendEntry])
    {
        super.init()
        
        self.entries = entries
    }
    
    @objc open func getMaximumEntrySize(withFont font: NSUIFont) -> CGSize
    {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var maxFormSize: CGFloat = 0.0

        for entry in entries
        {
            let formSize = entry.formSize.isNaN ? self.formSize : entry.formSize
            if formSize > maxFormSize
            {
                maxFormSize = formSize
            }
            
            guard let label = entry.label
                else { continue }
            
            let size = (label as NSString).size(withAttributes: [.font: font])
            
            if size.width > maxW
            {
                maxW = size.width
            }
            if size.height > maxH
            {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + maxFormSize + 