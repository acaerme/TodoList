import Swinject

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    let container: Container
    
    private init() {
        container = Container()
        
        container.register(NetworkManagerProtocol.self) { _ in
            NetworkManager(url: "https://dummyjson.com/todos")
        }
    }
}
