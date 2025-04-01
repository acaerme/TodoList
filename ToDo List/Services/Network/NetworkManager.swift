import Foundation

// MARK: - Protocol

protocol NetworkManagerProtocol {
    func fetchTodos(completion: @escaping (Result<NetworkResponse, Error>) -> Void)
}

// MARK: - Network Manager

final class NetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    
    let urlString: String
    private let networkQueue = DispatchQueue(label: "com.todolist.network", qos: .userInitiated)
    
    // MARK: - Initialization
    
    init(url: String) {
        self.urlString = url
    }
    
    // MARK: - Data Fetching
    
    func fetchTodos(completion: @escaping (Result<NetworkResponse, Error>) -> Void) {        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkErrors.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkErrors.requestFailed))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(NetworkErrors.badResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkErrors.requestFailed))
                return
            }
            
            do {
                let networkResponse = try JSONDecoder().decode(NetworkResponse.self, from: data)
                completion(.success(networkResponse))
            } catch {
                completion(.failure(NetworkErrors.failedToDecode))
            }
        }
        
        networkQueue.async {
            task.resume()
        }
    }
}
