
//
//  BarChartDataEntry.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class BarChartDataEntry: ChartDataEntry
{
    /// the values the stacked barchart holds
    private var _yVals: [Double]?
    
    /// the ranges for the individual stack values - automatically calculated
    private var _ranges: [Range]?
    
    /// the sum of all negative values this entry (if stacked) contains
    private var _negativeSum: Double = 0.0
    
    /// the sum of all positive values this entry (if stacked) contains
    private var _positiveSum: Double = 0.0
    
    public required init()
    {
        super.init()
    }
    
    /// Constructor for normal bars (not stacked).
    public override init(x: Double, y: Double)
    {
        super.init(x: x, y: y)
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, data: Any?)
    {
        self.init(x: x, y: y)
        self.data = data
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, icon: NSUIImage?)
    {
        self.init(x: x, y: y)
        self.icon = icon
    }
    
    /// Constructor for normal bars (not stacked).
    public convenience init(x: Double, y: Double, icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, y: y)
        self.icon = icon
        self.data = data
    }
    
    /// Constructor for stacked bar entries.
    @objc public init(x: Double, yValues: [Double])
    {
        super.init(x: x, y: BarChartDataEntry.calcSum(values: yValues))
        self._yVals = yValues
        calcPosNegSum()
        calcRanges()
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.data = data
    }

    /// Constructor for stacked bar entries. One data object for whole stack
    @objc public convenience init(x: Double, yValues: [Double], icon: NSUIImage?, data: Any?)
    {
        self.init(x: x, yValues: yValues)
        self.icon = icon
        self.data = data
    }
    
    @objc open func sumBelow(stackIndex :Int) -> Double
    {
        guard let yVals = _yVals else
        {
            return 0
        }
        
        var remainder: Double = 0.0
        var index = yVals.count - 1
        
        while (index > stackIndex && index >= 0)
        {
            remainder += yVals[index]
            index -= 1
        }
        
        return remainder
    }
    
    /// The sum of all negative values this entry (if stacked) contains. (this is a positive number)
    @objc open var negativeSum: Double
    {
        return _negativeSum
    }
    
    /// The sum of all positive values this entry (if stacked) contains.
    @objc open var positiveSum: Double
    {
        return _positiveSum
    }

    @objc open func calcPosNegSum()
    {
        (_negativeSum, _positiveSum) = _yVals?.reduce(into: (0,0)) { (result, y) in
            if y < 0
            {
                result.0 += -y
            }
            else
            {
                result.1 += y
            }
        } ?? (0,0)
    }
    
    /// Splits up the stack-values of the given bar-entry into Range objects.
    ///
    /// - Parameters:
    ///   - entry:
    /// - Returns:
    @objc open func calcRanges()