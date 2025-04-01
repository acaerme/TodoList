import XCTest
@testable import ToDo_List

final class TodoListInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoListInteractor!
    private var mockPresenter: MockTodoListPresenter!
    private var mockNetworkManager: MockNetworkManager!
    private var mockCoreDataManager: MockCoreDataManager!
    private let testUUID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockPresenter = MockTodoListPresenter()
        mockNetworkManager = MockNetworkManager()
        mockCoreDataManager = MockCoreDataManager()
        sut = TodoListInteractor(networkManager: mockNetworkManager, coreDataManager: mockCoreDataManager)
        sut.presenter = mockPresenter
        
        UserDefaults.standard.removeObject(forKey: "HasLaunchedBefore")
    }
    
    override func tearDown() {
        sut = nil
        mockPresenter = nil
        mockNetworkManager = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_fetchTodos_onFirstLaunch_fetchesFromAPI() {
        // Given
        mockNetworkManager.stubbedResponse = NetworkResponse(todos: [], total: 0, skip: 0, limit: 0)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "HasLaunchedBefore"))
        
        // When
        sut.fetchTodos()
        
        // Then
        XCTAssertTrue(mockNetworkManager.fetchTodosCalled)
    }
    
    func test_fetchTodos_onSubsequentLaunch_fetchesFromCoreData() {
        // Given
        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        UserDefaults.standard.synchronize()
        
        // When
        sut.fetchTodos()
        
        // Then
        XCTAssertTrue(mockCoreDataManager.getAllTodosCalled)
        XCTAssertFalse(mockNetworkManager.fetchTodosCalled)
    }
    
    func test_filterTodos_withEmptySearch_returnsAllTodos() {
        // Given
        let testTodos = createTestTodos()
        sut.presenter = mockPresenter
        
        // Simulate having todos already loaded
        NotificationCenter.default.post(name: NSNotification.Name("TodoAdded"),
                                      object: nil,
                                      userInfo: ["todo": testTodos[1]])
        NotificationCenter.default.post(name: NSNotification.Name("TodoAdded"),
                                      object: nil,
                                      userInfo: ["todo": testTodos[0]])
        
        let expectation = XCTestExpectation(description: "Wait for filtering")
        
        // When
        sut.filterTodos(with: "") { filteredTodos in
            // Then
            XCTAssertEqual(filteredTodos.count, 2)
            XCTAssertEqual(filteredTodos[0].title, "First Todo")
            XCTAssertEqual(filteredTodos[1].title, "Second Todo")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_filterTodos_withSearchText_returnsFilteredTodos() {
        // Given
        let testTodos = createTestTodos()
        sut.presenter = mockPresenter

        // Add todos
        NotificationCenter.default.post(name: NSNotification.Name("TodoAdded"),
                                      object: nil,
                                      userInfo: ["todo": testTodos[1]])
        NotificationCenter.default.post(name: NSNotification.Name("TodoAdded"),
                                      object: nil,
                                      userInfo: ["todo": testTodos[0]])

        let expectation = XCTestExpectation(description: "Wait for filtering")

        // When
        sut.filterTodos(with: "First") { filteredTodos in
            // Then
            XCTAssertEqual(filteredTodos.count, 1)
            XCTAssertEqual(filteredTodos[0].title, "First Todo")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_updateTodo_callsCoreDataManager() {
        // Given
        let todo = createTestTodos().first!
        
        // When
        sut.updateTodo(updatedTodo: todo)
        
        // Then
        XCTAssertTrue(mockCoreDataManager.updateTodoCalled)
        XCTAssertEqual(mockCoreDataManager.lastUpdatedTodo?.id, testUUID)
    }
    
    func test_delete_callsCoreDataManager() {
        // Given
        let todo = createTestTodos().first!
        
        // When
        sut.delete(id: todo.id)
        
        // Then
        XCTAssertTrue(mockCoreDataManager.deleteTodoCalled)
        XCTAssertEqual(mockCoreDataManager.lastDeletedId, testUUID)
    }
    
    func test_deleteAllTodos_callsCoreDataManager() {
        // When
        sut.deleteAllTodos()
        
        // Then
        XCTAssertTrue(mockCoreDataManager.deleteAllTodosCalled)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTodos() -> [Todo] {
        return [
            Todo(id: testUUID, title: "First Todo", description: "Test", date: Date(), completed: false),
            Todo(id: UUID(), title: "Second Todo", description: "Test", date: Date(), completed: true)
        ]
    }
}

// MARK: - Mocks

private final class MockTodoListPresenter: TodoListPresenterProtocol {
    var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    
    var lastTodos: [Todo]?
    private(set) var lastError: Error?
    
    func viewDidLoad() {}
    
    func updateTodosList(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            lastTodos = todos
        case .failure(let error):
            lastError = error
        }
    }
    
    func didSelectTodo(todo: Todo) {}
    func newTodoButtonTapped() {}
    func toggleTodoCompletion(for updatedTodo: Todo) {}
    func searchForTodos(with searchText: String) {}
    func editButtonTapped(todo: Todo?) {}
    func deleteButtonTapped(todo: Todo?) {}
    func shareButtonTapped(todo: Todo) {}
    func deleteAllTodosButtonTapped() {}
    func getTaskCountText(for count: Int) -> String { return "" }
    func contextMenuConfiguration(for todo: Todo, at indexPath: IndexPath) -> UIContextMenuConfiguration { return UIContextMenuConfiguration() }
}

private final class MockNetworkManager: NetworkManagerProtocol {
    private(set) var fetchTodosCalled = false
    var stubbedResponse: NetworkResponse?
    var stubbedError: Error?
    
    func fetchTodos(completion: @escaping (Result<NetworkResponse, Error>) -> Void) {
        fetchTodosCalled = true
        if let error = stubbedError {
            completion(.failure(error))
        } else {
            completion(.success(stubbedResponse ?? NetworkResponse(todos: [], total: 0, skip: 0, limit: 0)))
        }
    }
}

private final class MockCoreDataManager: CoreDataManager {
    private(set) var getAllTodosCalled = false
    private(set) var updateTodoCalled = false
    private(set) var deleteTodoCalled = false
    private(set) var deleteAllTodosCalled = false
    
    private(set) var lastUpdatedTodo: Todo?
    private(set) var lastDeletedId: UUID?
    
    var stubbedTodos: [Todo]?
    var stubbedError: Error?
    
    override func getAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        getAllTodosCalled = true
        if let error = stubbedError {
            completion(.failure(error))
        } else {
            completion(.success(stubbedTodos ?? []))
        }
    }
    
    override func updateTodo(todo: Todo, completion: ((Error?) -> Void)? = nil) {
        updateTodoCalled = true
        lastUpdatedTodo = todo
        completion?(nil)
    }
    
    override func deleteTodo(id: UUID, completion: ((Error?) -> Void)? = nil) {
        deleteTodoCalled = true
        lastDeletedId = id
        completion?(nil)
    }
    
    override func deleteAllTodos(completion: ((Error?) -> Void)? = nil) {
        deleteAllTodosCalled = true
        completion?(nil)
    }
}
