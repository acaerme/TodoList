//
//  NetworkManager.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 25/03/2025.
//

import Foundation

// MARK: - Protocol

protocol NetworkManagerProtocol {
    func fetchData() async throws -> NetworkResponse
}

// MARK: - Network Manager

final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    
    let urlString: String
    
    // MARK: - Initialization
    
    init(url: String) {
        self.urlString = url
    }
    
    // MARK: - Data Fetching
    
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
