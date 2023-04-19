
//
//  StockListVC.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import UIKit

class StockListVC: UIViewController {

    let tableView = UITableView()
    var data: [Data] = []
    var displayData: [Data] = []
    var isSearching = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        configureSearchController()
        getStockList()
        
    }
    
    private func configureViewController(){
        title = "Stock List"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    private func configureTableView() {
       
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.reuseID)
    }
    
    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search stock"
        navigationItem.searchController = searchController
    }
    
    private func getStockList() {
        NetworkManager.shared.getList { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case.success(let list):
                self.data = list.data
                self.displayData = list.data
                DispatchQueue.main.async {self.tableView.reloadData()}
        
                break
            case.failure(let error):
                print(error)
                break
            }
        }
    }


}

extension StockListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.reuseID) as! StockCell
        cell.set(data: displayData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destVC = StockInfoVC()
        destVC.set(stockName: displayData[indexPath.row].symbol, stockFullName: displayData[indexPath.row].name)
        navigationController?.pushViewController(destVC, animated: true)
        navigationController?.modalPresentationStyle = .fullScreen
        
    }
    
}

extension StockListVC: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            displayData = data
            isSearching = false
            DispatchQueue.main.async {self.tableView.reloadData()}
            return
        }
        isSearching = true
        let filterdata = data.filter { $0.symbol.lowercased().contains( filter.lowercased() ) }
        displayData = filterdata
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        displayData = data
        isSearching = false
        tableView.reloadData()
    }
}