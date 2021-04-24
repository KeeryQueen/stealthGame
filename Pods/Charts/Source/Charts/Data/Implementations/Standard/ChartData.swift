
//
//  ChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class ChartData: NSObject
{
    internal var _yMax: Double = -Double.greatestFiniteMagnitude
    internal var _yMin: Double = Double.greatestFiniteMagnitude
    internal var _xMax: Double = -Double.greatestFiniteMagnitude
    internal var _xMin: Double = Double.greatestFiniteMagnitude
    internal var _leftAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _leftAxisMin: Double = Double.greatestFiniteMagnitude
    internal var _rightAxisMax: Double = -Double.greatestFiniteMagnitude
    internal var _rightAxisMin: Double = Double.greatestFiniteMagnitude
    
    internal var _dataSets = [IChartDataSet]()
    
    public override init()
    {
        super.init()
        
        _dataSets = [IChartDataSet]()
    }
    
    @objc public init(dataSets: [IChartDataSet]?)
    {
        super.init()
        
        _dataSets = dataSets ?? [IChartDataSet]()
        
        self.initialize(dataSets: _dataSets)
    }
    
    @objc public convenience init(dataSet: IChartDataSet?)
    {
        self.init(dataSets: dataSet === nil ? nil : [dataSet!])
    }
    
    internal func initialize(dataSets: [IChartDataSet])
    {
        notifyDataChanged()
    }
    
    /// Call this method to let the ChartData know that the underlying data has changed.
    /// Calling this performs all necessary recalculations needed when the contained data has changed.
    @objc open func notifyDataChanged()
    {
        calcMinMax()
    }
    
    @objc open func calcMinMaxY(fromX: Double, toX: Double)
    {
        _dataSets.forEach { $0.calcMinMaxY(fromX: fromX, toX: toX) }
        // apply the new data
        calcMinMax()
    }
    
    /// calc minimum and maximum y value over all datasets
    @objc open func calcMinMax()
    {
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        _dataSets.forEach { calcMinMax(dataSet: $0) }
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        // left axis
        let firstLeft = getFirstLeft(dataSets: dataSets)
        
        if firstLeft !== nil
        {
            _leftAxisMax = firstLeft!.yMax
            _leftAxisMin = firstLeft!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .left
                {
                    if dataSet.yMin < _leftAxisMin
                    {
                        _leftAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _leftAxisMax
                    {
                        _leftAxisMax = dataSet.yMax
                    }
                }
            }
        }
        
        // right axis
        let firstRight = getFirstRight(dataSets: dataSets)
        
        if firstRight !== nil
        {
            _rightAxisMax = firstRight!.yMax
            _rightAxisMin = firstRight!.yMin
            
            for dataSet in _dataSets
            {
                if dataSet.axisDependency == .right
                {
                    if dataSet.yMin < _rightAxisMin
                    {
                        _rightAxisMin = dataSet.yMin
                    }
                    
                    if dataSet.yMax > _rightAxisMax
                    {
                        _rightAxisMax = dataSet.yMax
                    }
                }
            }
        }
    }
    
    /// Adjusts the current minimum and maximum values based on the provided Entry object.
    @objc open func calcMinMax(entry e: ChartDataEntry, axis: YAxis.AxisDependency)
    {
        if _yMax < e.y
        {
            _yMax = e.y
        }
        
        if _yMin > e.y
        {
            _yMin = e.y
        }
        
        if _xMax < e.x
        {
            _xMax = e.x
        }
        
        if _xMin > e.x
        {
            _xMin = e.x
        }
        
        if axis == .left
        {
            if _leftAxisMax < e.y
            {
                _leftAxisMax = e.y
            }
            
            if _leftAxisMin > e.y
            {
                _leftAxisMin = e.y
            }
        }
        else
        {
            if _rightAxisMax < e.y
            {
                _rightAxisMax = e.y
            }
            
            if _rightAxisMin > e.y
            {
                _rightAxisMin = e.y
            }
        }
    }
    
    /// Adjusts the minimum and maximum values based on the given DataSet.
    @objc open func calcMinMax(dataSet d: IChartDataSet)
    {
        if _yMax < d.yMax
        {
            _yMax = d.yMax
        }
        
        if _yMin > d.yMin
        {
            _yMin = d.yMin
        }
        
        if _xMax < d.xMax
        {
            _xMax = d.xMax
        }
        
        if _xMin > d.xMin
        {
            _xMin = d.xMin
        }
        
        if d.axisDependency == .left
        {
            if _leftAxisMax < d.yMax
            {
                _leftAxisMax = d.yMax
            }
            
            if _leftAxisMin > d.yMin
            {
                _leftAxisMin = d.yMin
            }
        }
        else
        {
            if _rightAxisMax < d.yMax
            {
                _rightAxisMax = d.yMax
            }
            
            if _rightAxisMin > d.yMin
            {
                _rightAxisMin = d.yMin
            }
        }
    }
    
    /// The number of LineDataSets this object contains
    @objc open var dataSetCount: Int
    {
        return _dataSets.count
    }
    
    /// The smallest y-value the data object contains.
    @objc open var yMin: Double
    {
        return _yMin
    }
    
    @nonobjc
    open func getYMin() -> Double
    {
        return _yMin
    }
    
    @objc open func getYMin(axis: YAxis.AxisDependency) -> Double
    {
        if axis == .left
        {
            if _leftAxisMin == Double.greatestFiniteMagnitude
            {
                return _rightAxisMin
            }
            else
            {
                return _leftAxisMin
            }
        }
        else
        {
            if _rightAxisMin == Double.greatestFiniteMagnitude
            {
                return _leftAxisMin