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
        typeCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        fullnameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        codenameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        codenameLabel.textAlignment = .left
        
        typeCurrencyLabel.font = UIFont.systemFont(ofSize: 15, weight: .ultraLight)
        typeCurrencyLabel.textAlignment = .left
        
        fullnameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        fullnameLabel.textAlignment = .left
        fullnameLabel.lineBreakMode = .byClipping
        fullnameLabel.numberOfLines = 3
        fullnameLabel.minimumScaleFactor = 0.8
        fullnameLabel.adjustsFontSizeToFitWidth = true
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            codenameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            codenameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            codenameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width / 2),
            codenameLabel.heightAnchor.constraint(equalToConstant: contentView.frame.height / 2),
            
            typeCurrencyLabel.topAnchor.constraint(equalTo: codenameLabel.bottomAnchor, constant: 2),
            typeCurrencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            typeCurrencyLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width / 2),
            typeCurrencyLabel.heightAnchor.constraint(equalToConstant: contentView.frame.height / 2),
            
            fullnameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            fullnameLabel.leadingAnchor.constraint(equalTo: codenameLabel.trailingAnchor,constant: 75),
            fullnameLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width / 2 - 25),
            fullnameLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
