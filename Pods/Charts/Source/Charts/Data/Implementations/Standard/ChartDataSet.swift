
//
//  ChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

/// Determines how to round DataSet index values for `ChartDataSet.entryIndex(x, rounding)` when an exact x-value is not found.
@objc
public enum ChartDataSetRounding: Int
{
    case up = 0
    case down = 1
    case closest = 2
}

/// The DataSet class represents one group or type of entries (Entry) in the Chart that belong together.
/// It is designed to logically separate different groups of values inside the Chart (e.g. the values for a specific line in the LineChart, or the values of a specific group of bars in the BarChart).
open class ChartDataSet: ChartBaseDataSet
{
    public required init()
    {
        entries = []

        super.init()
    }
    
    public override convenience init(label: String?)
    {
        self.init(entries: nil, label: label)
    }
    
    @objc public init(entries: [ChartDataEntry]?, label: String?)
    {
        self.entries = entries ?? []

        super.init(label: label)

        self.calcMinMax()
    }
    
    @objc public convenience init(entries: [ChartDataEntry]?)
    {
        self.init(entries: entries, label: "DataSet")
    }
    
    // MARK: - Data functions and accessors

    /// - Note: Calls `notifyDataSetChanged()` after setting a new value.
    /// - Returns: The array of y-values that this DataSet represents.
    /// the entries that this dataset represents / holds together
    @available(*, unavailable, renamed: "entries")
    @objc
    open var values: [ChartDataEntry] { return entries }

    @objc
    open private(set) var entries: [ChartDataEntry]

    /// Used to replace all entries of a data set while retaining styling properties.
    /// This is a separate method from a setter on `entries` to encourage usage
    /// of `Collection` conformances.
    ///
    /// - Parameter entries: new entries to replace existing entries in the dataset
    @objc
    public func replaceEntries(_ entries: [ChartDataEntry]) {
        self.entries = entries
        notifyDataSetChanged()
    }

    /// maximum y-value in the value array
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum y-value in the value array
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    
    /// maximum x-value in the value array
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    
    /// minimum x-value in the value array
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    
    open override func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }

        forEach(calcMinMax)
    }
    
    open override func calcMinMaxY(fromX: Double, toX: Double)
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude

        guard !isEmpty else { return }
        
        let indexFrom = entryIndex(x: fromX, closestToY: Double.nan, rounding: .down)
        let indexTo = entryIndex(x: toX, closestToY: Double.nan, rounding: .up)
        
        guard !(indexTo < indexFrom) else { return }
        // only recalculate y
        self[indexFrom...indexTo].forEach(calcMinMaxY)
    }
    
    @objc open func calcMinMaxX(entry e: ChartDataEntry)
    {
        if e.x < _xMin
        {
            _xMin = e.x
        }
        if e.x > _xMax
        {
            _xMax = e.x
        }
    }
    
    @objc open func calcMinMaxY(entry e: ChartDataEntry)
    {
        if e.y < _yMin
        {
            _yMin = e.y
        }
        if e.y > _yMax
        {
            _yMax = e.y
        }
    }
    
    /// Updates the min and max x and y value of this DataSet based on the given Entry.
    ///
    /// - Parameters:
    ///   - e:
    internal func calcMinMax(entry e: ChartDataEntry)
    {
        calcMinMaxX(entry: e)
        calcMinMaxY(entry: e)
    }
    
    /// The minimum y-value this DataSet holds
    open override var yMin: Double { return _yMin }
    
    /// The maximum y-value this DataSet holds
    open override var yMax: Double { return _yMax }
    
    /// The minimum x-value this DataSet holds
    open override var xMin: Double { return _xMin }
    
    /// The maximum x-value this DataSet holds
    open override var xMax: Double { return _xMax }
    
    /// The number of y-values this DataSet represents
    @available(*, deprecated, message: "Use `count` instead")
    open override var entryCount: Int { return count }
    
    /// - Throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    /// - Returns: The entry object found at the given index (not x-value!)
    @available(*, deprecated, message: "Use `subscript(index:)` instead.")
    open override func entryForIndex(_ i: Int) -> ChartDataEntry?
    {
        guard i >= startIndex, i < endIndex else {
            return nil
        }
        return self[i]
    }
    
    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    {
        let index = entryIndex(x: xValue, closestToY: yValue, rounding: rounding)
        if index > -1
        {
            return self[index]
        }
        return nil
    }
    
    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    open override func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> ChartDataEntry?
    {
        return entryForXValue(xValue, closestToY: yValue, rounding: .closest)
    }
    
    /// - Returns: All Entry objects found at the given xIndex with binary search.
    /// An empty array if no Entry object at that index.
    open override func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = startIndex
        var high = endIndex - 1
        
        while low <= high
        {
            var m = (high + low) / 2
            var entry = self[m]
            
            // if we have a match
            if xValue == entry.x
            {
                while m > 0 && self[m - 1].x == xValue
                {
                    m -= 1
                }
                
                high = endIndex
                
                // loop over all "equal" entries
                while m < high
                {
                    entry = self[m]
                    if entry.x == xValue
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                    
                    m += 1
                }
                
                break
            }
            else
            {
                if xValue > entry.x
                {
                    low = m + 1
                }
                else
                {
                    high = m - 1
                }
            }
        }
        
        return entries
    }
    
    /// - Parameters:
    ///   - xValue: x-value of the entry to search for
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: Rounding method if exact value was not found
    /// - Returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    open override func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    {
        var low = startIndex
        var high = endIndex - 1
        var closest = high
        
        while low < high
        {
            let m = (low + high) / 2
            
            let d1 = self[m].x - xValue
            let d2 = self[m + 1].x - xValue
            let ad1 = abs(d1), ad2 = abs(d2)
            
            if ad2 < ad1
            {
                // [m + 1] is closer to xValue
                // Search in an higher place
                low = m + 1
            }
            else if ad1 < ad2
            {
                // [m] is closer to xValue
                // Search in a lower place
                high = m
            }
            else
            {
                // We have multiple sequential x-value with same distance
                
                if d1 >= 0.0
                {
                    // Search in a lower place
                    high = m
                }
                else if d1 < 0.0
                {
                    // Search in an higher place
                    low = m + 1
                }
            }
            
            closest = high
        }
        
        if closest != -1