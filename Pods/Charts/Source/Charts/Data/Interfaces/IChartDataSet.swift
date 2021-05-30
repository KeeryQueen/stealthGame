
//
//  IChartDataSet.swift
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

@objc
public protocol IChartDataSet
{
    // MARK: - Data functions and accessors
    
    /// Use this method to tell the data set that the underlying data has changed
    func notifyDataSetChanged()
    
    /// Calculates the minimum and maximum x and y values (_xMin, _xMax, _yMin, _yMax).
    func calcMinMax()
    
    /// Calculates the min and max y-values from the Entry closest to the given fromX to the Entry closest to the given toX value.
    /// This is only needed for the autoScaleMinMax feature.
    func calcMinMaxY(fromX: Double, toX: Double)
    
    /// The minimum y-value this DataSet holds
    var yMin: Double { get }
    
    /// The maximum y-value this DataSet holds
    var yMax: Double { get }
    
    /// The minimum x-value this DataSet holds
    var xMin: Double { get }
    
    /// The maximum x-value this DataSet holds
    var xMax: Double { get }
    
    /// The number of y-values this DataSet represents
    var entryCount: Int { get }
    
    /// - Throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    /// - Returns: The entry object found at the given index (not x-value!)
    func entryForIndex(_ i: Int) -> ChartDataEntry?
    
    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: determine whether to round up/down/closest if there is no Entry matching the provided x-value
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value according to the rounding.
    /// nil if no Entry object at that x-value.
    func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> ChartDataEntry?
    
    /// - Parameters:
    ///   - xValue: the x-value
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    /// - Returns: The first Entry object found at the given x-value with binary search.
    /// If the no Entry at the specified x-value is found, this method returns the Entry at the closest x-value.
    /// nil if no Entry object at that x-value.
    func entryForXValue(
        _ xValue: Double,
        closestToY yValue: Double) -> ChartDataEntry?
    
    /// - Returns: All Entry objects found at the given x-value with binary search.
    /// An empty array if no Entry object at that x-value.
    func entriesForXValue(_ xValue: Double) -> [ChartDataEntry]
    
    /// - Parameters:
    ///   - xValue: x-value of the entry to search for
    ///   - closestToY: If there are multiple y-values for the specified x-value,
    ///   - rounding: Rounding method if exact value was not found
    /// - Returns: The array-index of the specified entry.
    /// If the no Entry at the specified x-value is found, this method returns the index of the Entry at the closest x-value according to the rounding.
    func entryIndex(
        x xValue: Double,
        closestToY yValue: Double,
        rounding: ChartDataSetRounding) -> Int
    
    /// - Parameters:
    ///   - e: the entry to search for
    /// - Returns: The array-index of the specified entry
    func entryIndex(entry e: ChartDataEntry) -> Int
    
    /// Adds an Entry to the DataSet dynamically.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// Entries are added to the end of the list.
    ///
    /// - Parameters:
    ///   - e: the entry to add
    /// - Returns: `true` if the entry was added successfully, `false` ifthis feature is not supported
    func addEntry(_ e: ChartDataEntry) -> Bool
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index in the values array respective to their x-position.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// Entries are added to the end of the list.
    ///
    /// - Parameters:
    ///   - e: the entry to add
    /// - Returns: `true` if the entry was added successfully, `false` ifthis feature is not supported
    func addEntryOrdered(_ e: ChartDataEntry) -> Bool
    
    /// Removes an Entry from the DataSet dynamically.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - Parameters:
    ///   - entry: the entry to remove
    /// - Returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeEntry(_ entry: ChartDataEntry) -> Bool
    
    /// Removes the Entry object at the given index in the values array from the DataSet.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - Parameters:
    ///   - index: the index of the entry to remove
    /// - Returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeEntry(index: Int) -> Bool
    
    /// Removes the Entry object closest to the given x-value from the DataSet.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - Parameters:
    ///   - x: the x-value to remove
    /// - Returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeEntry(x: Double) -> Bool
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - Returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeFirst() -> Bool
    
    /// Removes the last Entry (at index 0) of this DataSet from the entries array.
    ///
    /// *optional feature, can return `false` ifnot implemented*
    ///
    /// - Returns: `true` if the entry was removed successfully, `false` ifthe entry does not exist or if this feature is not supported
    func removeLast() -> Bool
    
    /// Checks if this DataSet contains the specified Entry.
    ///
    /// - Returns: `true` if contains the entry, `false` ifnot.
    func contains(_ e: ChartDataEntry) -> Bool
    
    /// Removes all values from this DataSet and does all necessary recalculations.
    ///
    /// *optional feature, could throw if not implemented*
    func clear()
    
    // MARK: - Styling functions and accessors
    
    /// The label string that describes the DataSet.
    var label: String? { get }
    
    /// The axis this DataSet should be plotted against.
    var axisDependency: YAxis.AxisDependency { get }
    
    /// List representing all colors that are used for drawing the actual values for this DataSet
    var valueColors: [NSUIColor] { get }
    
    /// All the colors that are used for this DataSet.
    /// Colors are reused as soon as the number of Entries the DataSet represents is higher than the size of the colors array.
    var colors: [NSUIColor] { get }
    
    /// - Returns: The color at the given index of the DataSet's color array.
    /// This prevents out-of-bounds by performing a modulus on the color index, so colours will repeat themselves.
    func color(atIndex: Int) -> NSUIColor
    
    func resetColors()
    
    func addColor(_ color: NSUIColor)
    
    func setColor(_ color: NSUIColor)
    
    /// if true, value highlighting is enabled
    var highlightEnabled: Bool { get set }
    
    /// `true` if value highlighting is enabled for this dataset
    var isHighlightEnabled: Bool { get }