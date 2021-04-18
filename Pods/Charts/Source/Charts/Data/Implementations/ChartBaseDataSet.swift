
//
//  BaseDataSet.swift
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


open class ChartBaseDataSet: NSObject, IChartDataSet, NSCopying
{
    public required override init()
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(.labelOrBlack)
    }
    
    @objc public init(label: String?)
    {
        super.init()
        
        // default color
        colors.append(NSUIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
        valueColors.append(.labelOrBlack)
        
        self.label = label
    }
    
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    open func notifyDataSetChanged()
    {
        calcMinMax()
    }
    
    open func calcMinMax()
    {
        fatalError("calcMinMax is not implemented in ChartBaseDataSet")
    }
    
    open func calcMinMaxY(fromX: Double, toX: Double)
    {
        fatalError("calcMinMaxY(fromX:, toX:) is not implemented in ChartBaseDataSet")
    }
    
    open var yMin: Double
    {
        fatalError("yMin is not implemented in ChartBaseDataSet")
    }
    
    open var yMax: Double
    {
        fatalError("yMax is not implemented in ChartBaseDataSet")
    }
    
    open var xMin: Double
    {
        fatalError("xMin is not implemented in ChartBaseDataSet")
    }
    
    open var xMax: Double
    {
        fatalError("xMax is not implemented in ChartBaseDataSet")
    }
    
    open var entryCount: Int
    {
        fatalError("entryCount is not implemented in ChartBaseDataSet")
    }
        
    open func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        fatalError("entryForIndex is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXValue(
        _ x: Double,
        closestToY y: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        fatalError("entryForXValue(x, closestToY, rounding) is not implemented in ChartBaseDataSet")
    }
    
    open func entryForXValue(
        _ x: Double,
        closestToY y: Double) -> ChartDataEntry?
    {
        fatalError("entryForXValue(x, closestToY) is not implemented in ChartBaseDataSet")
    }
    
    open func entriesForXValue(_ x: Double) -> [ChartDataEntry]
    {
        fatalError("entriesForXValue is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(
        x xValue: Double,
        closestToY y: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        fatalError("entryIndex(x, closestToY, rounding) is not implemented in ChartBaseDataSet")
    }
    
    open func entryIndex(entry e: ChartDataEntry) -> Int
    {
        fatalError("entryIndex(entry) is not implemented in ChartBaseDataSet")
    }
    
    open func addEntry(_ e: ChartDataEntry) -> Bool
    {
        fatalError("addEntry is not implemented in ChartBaseDataSet")
    }
    
    open func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    {
        fatalError("addEntryOrdered is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func removeEntry(_ entry: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    @discardableResult open func removeEntry(index: Int) -> Bool
    {
        if let entry = entryForIndex(index)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    @discardableResult open func removeEntry(x: Double) -> Bool
    {
        if let entry = entryForXValue(x, closestToY: Double.nan)
        {
            return removeEntry(entry)
        }
        return false
    }
    
    @discardableResult open func removeFirst() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(0)
            {
                return removeEntry(entry)
            }
        }
        return false
    }
    
    @discardableResult open func removeLast() -> Bool
    {
        if entryCount > 0
        {
            if let entry = entryForIndex(entryCount - 1)
            {
                return removeEntry(entry)
            }
        }
        return false
    }
    
    open func contains(_ e: ChartDataEntry) -> Bool
    {
        fatalError("removeEntry is not implemented in ChartBaseDataSet")
    }
    
    open func clear()
    {
        fatalError("clear is not implemented in ChartBaseDataSet")
    }
    
    // MARK: - Styling functions and accessors
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    open var colors = [NSUIColor]()
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    open var valueColors = [NSUIColor]()

    /// The label string that describes the DataSet.
    open var label: String? = "DataSet"
    
    /// The axis this DataSet should be plotted against.
    open var axisDependency = YAxis.AxisDependency.left
    
    /// - Returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    open func color(atIndex index: Int) -> NSUIColor
    {
        var index = index
        if index < 0
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    /// Resets all colors of this DataSet and recreates the colors array.
    open func resetColors()
    {
        colors.removeAll(keepingCapacity: false)