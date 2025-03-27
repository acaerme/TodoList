import Foundation

// MARK: - Protocol

protocol NetworkManagerProtocol {
    func fetchTodos() async throws -> NetworkResponse
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
    
    func fetchTodos() async throws -> NetworkResponse {
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
