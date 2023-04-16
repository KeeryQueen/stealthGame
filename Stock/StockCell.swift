//
//  StockCell.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import UIKit

class StockCell: UITableViewCell {

    static let reuseID = "StockCell"
    let codenameLabel = UILabel()
    let typeCurrencyLabel = UILabel()
    let fullnameLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(data: Data) {
        codenameLabel.text =  "     " + data.symbol
        typeCurrencyLabel.text = "      " + data.type + " " + data.currency
        fullnameLabel.text = data.name
    }
    
    private func configureUI() {
        contentView.addSubview(codenameLabel)
        contentView.addSubview(typeCurrencyLabel)
        contentView.addSubview(fullnameLabel)
        
        codenameLabel.translatesAutoresizingMaskIntoConstraints = false
        typeCurrencyLabel.translat