
//
//  NetworkManager.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() { }
    
    func getList(completed: @escaping (Result<List, ErrorMessage>) -> Void) {
        
        let endpoint = "https://api.twelvedata.com/stocks?country=US&type=common_stock"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.connectionFaild))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let list = try decoder.decode(List.self, from: data)
                completed(.success(list))
            } catch {
                completed(.failure(.invalidDecodeData))
            }
        }
        
        task.resume()
    }
    
    func getStock(from name: String, completed: @escaping (Result<Stock, ErrorMessage>) -> Void) {
        let endpoint = "https://api.twelvedata.com/time_series?symbol=\(name)&interval=1day&format=JSON&timezone=Asia/Taipei&apikey=a8aff80cc14f488bbae56354b9dbda89"
        
        guard let url = URL(string: endpoint) else {
            completed(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.connectionFaild))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let stock = try decoder.decode(Stock.self, from: data)
                completed(.success(stock))
            } catch {
                completed(.failure(.invalidDecodeData))
            }
        }
        
        task.resume()
    }
}

