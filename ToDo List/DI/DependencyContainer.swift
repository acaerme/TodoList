import Swinject

final class DependencyContainer {
    
    // MARK: - Properties
    
    static let shared = DependencyContainer()
    
    let container: Container
    
    // MARK: - Initializer
    
    private init() {
        container = Container()
        
        container.register(NetworkManagerProtocol.self) { _ in
            NetworkManager(url: "https://dummyjson.com/todos")
        }.inObjectScope(.container)
        
        container.register(CoreDataManagerProtocol.self) { _ in
            CoreDataManager()
        }.inObjectScope(.container)
    }
}
