
//
//  CombinedChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

open class CombinedChartData: BarLineScatterCandleBubbleChartData
{
    private var _lineData: LineChartData!
    private var _barData: BarChartData!
    private var _scatterData: ScatterChartData!
    private var _candleData: CandleChartData!
    private var _bubbleData: BubbleChartData!
    
    public override init()
    {
        super.init()
    }
    
    public override init(dataSets: [IChartDataSet]?)
    {
        super.init(dataSets: dataSets)
    }
    
    @objc open var lineData: LineChartData!
    {
        get
        {
            return _lineData
        }
        set
        {
            _lineData = newValue
            notifyDataChanged()
        }
    }
    
    @objc open var barData: BarChartData!
    {
        get
        {
            return _barData
        }
        set
        {
            _barData = newValue
            notifyDataChanged()
        }
    }
    
    @objc open var scatterData: ScatterChartData!
    {
        get
        {
            return _scatterData
        }
        set
        {
            _scatterData = newValue
            notifyDataChanged()
        }
    }
    
    @objc open var candleData: CandleChartData!
    {
        get
        {
            return _candleData
        }
        set
        {
            _candleData = newValue
            notifyDataChanged()
        }
    }
    
    @objc open var bubbleData: BubbleChartData!
    {
        get
        {
            return _bubbleData
        }
        set
        {
            _bubbleData = newValue
            notifyDataChanged()
        }
    }
    
    open override func calcMinMax()
    {
        _dataSets.removeAll()
        
        _yMax = -Double.greatestFiniteMagnitude
        _yMin = Double.greatestFiniteMagnitude
        _xMax = -Double.greatestFiniteMagnitude
        _xMin = Double.greatestFiniteMagnitude
        
        _leftAxisMax = -Double.greatestFiniteMagnitude
        _leftAxisMin = Double.greatestFiniteMagnitude
        _rightAxisMax = -Double.greatestFiniteMagnitude
        _rightAxisMin = Double.greatestFiniteMagnitude
        
        let allData = self.allData
        
        for data in allData
        {
            data.calcMinMax()
            
            let sets = data.dataSets
            _dataSets.append(contentsOf: sets)
            
            if data.yMax > _yMax
            {
                _yMax = data.yMax
            }
            
            if data.yMin < _yMin
            {
                _yMin = data.yMin
            }
            
            if data.xMax > _xMax
            {
                _xMax = data.xMax
            }
            
            if data.xMin < _xMin
            {
                _xMin = data.xMin
            }

            for dataset in sets
            {
                if dataset.axisDependency == .left
                {
                    if dataset.yMax > _leftAxisMax
                    {
                        _leftAxisMax = dataset.yMax
                    }
                    if dataset.yMin < _leftAxisMin
                    {
                        _leftAxisMin = dataset.yMin
                    }
                }
                else
                {
                    if dataset.yMax > _rightAxisMax
                    {
                        _rightAxisMax = dataset.yMax
                    }
                    if dataset.yMin < _rightAxisMin
                    {
                        _rightAxisMin = dataset.yMin
                    }
                }
            }
        }