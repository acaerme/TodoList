//
//  DependencyContainer.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// DependencyContainer.swift

import Swinject

class DependencyContainer {
    static let shared = DependencyContainer()
    
    let container: Container
    
    private init() {
        container = Container()
        
        // Register NetworkManager
        container.register(NetworkManagerProtocol.self) { _ in
            NetworkManager(url: "https://dummyjson.com/todos")
        }
    }
}
