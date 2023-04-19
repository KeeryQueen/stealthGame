
//
//  StockInfoVC.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import UIKit
import Charts

class StockInfoVC: UIViewController{

    var stockName: String = ""
    var stockFullName: String = ""
    let symbolLabel = UILabel()
    let nameLabel = UILabel()
    let currentPriceText = UILabel()
    let currentPrice = UILabel()
    var stock: Stock!
    let chartView = CandleStickChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureLabelUI()
        getStock()
        
    }

    func set(stockName: String, stockFullName: String) {
        self.stockName = stockName
        self.stockFullName = stockFullName
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func setText() {
        self.symbolLabel.text = self.stock.meta.symbol
        self.nameLabel.text = self.stockFullName
        self.currentPriceText.text = "Current Value (USD)"
        self.currentPrice.text = "$ " + self.stock.values[0].close
    }
    
    private func configureLabelUI() {
        view.addSubview(symbolLabel)
        view.addSubview(nameLabel)
        view.addSubview(currentPrice)
        view.addSubview(currentPriceText)
                
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPrice.translatesAutoresizingMaskIntoConstraints = false
        currentPriceText.translatesAutoresizingMaskIntoConstraints = false
        
        symbolLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        symbolLabel.textAlignment = .left
        
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .ultraLight)
        nameLabel.textAlignment = .left
        
        currentPrice.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        currentPriceText.textAlignment = .left
        
        currentPrice.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        currentPrice.textAlignment = .left
        
        let padding: CGFloat = 20
        let labelPadding: CGFloat = 10
        let offset: CGFloat = 50
        
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: padding + offset),
            symbolLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            symbolLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 6),
            symbolLabel.heightAnchor.constraint(equalToConstant: 25),
            
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: padding + offset),
            nameLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor, constant: 0),
            nameLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 1.5),
            nameLabel.heightAnchor.constraint(equalToConstant: 25),
            
            currentPriceText.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: labelPadding),
            currentPriceText.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            currentPriceText.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            currentPriceText.heightAnchor.constraint(equalToConstant: 25),
            
            currentPrice.topAnchor.constraint(equalTo: currentPriceText.bottomAnchor, constant: labelPadding),
            currentPrice.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
            currentPrice.widthAnchor.constraint(equalToConstant: view.frame.width / 2 ),
            currentPrice.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func getStock() {
        NetworkManager.shared.getStock(from: stockName) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case.success(let stock):
                self.stock = stock
                DispatchQueue.main.async {
                    self.configureChart()
                    self.setText()
                }
                break
            case.failure(let error):
                print(error.rawValue)
                break
            }
        }
    }

}

extension StockInfoVC: ChartViewDelegate {
    private func configureChart() {
        chartView.delegate = self
        view.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 20
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: currentPrice.bottomAnchor, constant: padding),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
            
        ])
        
        candleStickConfigure()
        setCandleStickData()
    }
    
    private func setCandleStickData() {
        let entry = (0..<stock.values.count).map { (i) -> CandleChartDataEntry in
            let high = Double(stock.values[stock.values.count - 1 - i].high)
            let low = Double(stock.values[stock.values.count - 1 - i].low)
            let open = Double(stock.values[stock.values.count - 1 - i].open)
            let close = Double(stock.values[stock.values.count - 1 - i].close)
            return CandleChartDataEntry(x: Double(i), shadowH: high!, shadowL: low!, open: open!, close: close!, icon: UIImage(named: "icon"))
        }

        let set = CandleChartDataSet(entries: entry, label: "Price")
        set.axisDependency = .left
        set.setColor(UIColor(white: 80/255, alpha: 1))
        set.drawIconsEnabled = false
        set.shadowColor = .darkGray
        set.shadowWidth = 0.7
        set.decreasingColor = .red
        set.decreasingFilled = true
        set.increasingColor = UIColor(red: 122/255, green: 242/255, blue: 84/255, alpha: 1)
        set.increasingFilled = false
        set.neutralColor = .blue
        let data = CandleChartData(dataSet: set)
        data.setDrawValues(false)
        chartView.data = data
    }
    
    private func candleStickConfigure() {
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        //chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.gridBackgroundColor = .clear
        chartView.drawBordersEnabled = false
        chartView.xAxis.gridColor = .systemBackground
        
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.orientation = .vertical
        chartView.legend.drawInside = false
        chartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 10)!
        
        chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        chartView.leftAxis.spaceTop = 0.3
        chartView.leftAxis.spaceBottom = 0.3
        chartView.leftAxis.axisMinimum = 0
        
        chartView.rightAxis.enabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!


    }
    
}