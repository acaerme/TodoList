//
//  NetworkManager.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 25/03/2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchData() async throws -> NetworkResponse
}

final class NetworkManager: NetworkManagerProtocol {
    let urlString: String
    
    init(url: String) {
        self.urlString = url
    }
    
    func fetchData() async throws -> NetworkResponse {
        guard let url = URL(string: urlString) else {
            throw NetworkErrors.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw NetworkErrors.requestFailed
        }
        
        guard response.statusCode == 200 else {
            throw NetworkErrors.badResponse
        }
        
        do {
            let networkResponse = try JSONDecoder().decode(NetworkResponse.self, from: data)
            return networkResponse
        } catch {
            throw NetworkErrors.failedToDecode
        }
    }
}
