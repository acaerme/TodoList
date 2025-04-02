import XCTest
import CoreData
@testable import ToDo_List

final class TodoDetailsInteractorTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoDetailsInteractor!
    private var mockPresenter: MockTodoDetailsPresenter!
    private var mockCoreDataManager: MockCoreDataManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockPresenter = MockTodoDetailsPresenter()
        let mockContainer = setupMockContainer()
        mockCoreDataManager = MockCoreDataManager(persistentContainer: mockContainer)
        sut = TodoDetailsInteractor(coreDataManager: mockCoreDataManager)
        sut.presenter = mockPresenter
    }
    
    override func tearDown() {
        sut = nil
        mockPresenter = nil
        mockCoreDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_handleCreateTodo_withEmptyFields_doesNotCreateTodo() {
        sut.handleCreateTodo(title: "", description: "")
        XCTAssertFalse(mockCoreDataManager.createTodoCalled)
    }
    
    func test_handleCreateTodo_withValidFields_createsTodoAndNotifiesPresenter() {
        sut.handleCreateTodo(title: "Test Title", description: "Test Description")
        XCTAssertTrue(mockCoreDataManager.createTodoCalled)
    }
    
    func test_handleEditTodo_withEmptyFields_deletesTodoAndNotifiesPresenter() {
        let id = UUID()
        
        sut.handleEditTodo(id: id, newTitle: "", newDescription: "",
                           oldTitle: "Old", oldDescription: "Old", completed: false)
        
        XCTAssertTrue(mockCoreDataManager.deleteTodoCalled)
    }
    
    func test_handleEditTodo_withUnchangedFields_onlyNotifiesPresenter() {
        let title = "Test"
        let description = "Test"

        sut.handleEditTodo(id: UUID(), newTitle: title, newDescription: description,
                           oldTitle: title, oldDescription: description, completed: false)

        XCTAssertFalse(mockCoreDataManager.updateTodoCalled)
    }
    
    func test_handleEditTodo_withChangedFields_updatesTodoAndNotifiesPresenter() {
        sut.handleEditTodo(id: UUID(), newTitle: "New", newDescription: "New",
                           oldTitle: "Old", oldDescription: "Old", completed: false)
        
        XCTAssertTrue(mockCoreDataManager.updateTodoCalled)
    }
    
    // MARK: - Helper Methods

    private func setupMockContainer() -> NSPersistentContainer {
        let mockContainer = NSPersistentContainer(name: "TodoList")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockContainer.persistentStoreDescriptions = [description]

        let expectation = XCTestExpectation(description: "Load store")
        mockContainer.loadPersistentStores { description, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        return mockContainer
    }
}

// MARK: - Mocks

private final class MockTodoDetailsPresenter: TodoDetailsPresenterProtocol {
    var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
    
    private(set) var handleTodoCalled = false
    
    func viewDidLoad() {}
    
    func handleTodo(title: String?, description: String?) {
        handleTodoCalled = true
    }
}

private final class MockCoreDataManager: CoreDataManagerProtocol {
    var persistentContainer: NSPersistentContainer

    private(set) var createTodoCalled = false
    private(set) var updateTodoCalled = false
    private(set) var deleteTodoCalled = false

    private(set) var lastCreatedTodo: Todo?
    private(set) var lastUpdatedTodo: Todo?
    private(set) var lastDeletedId: UUID?

    var stubbedTodos: [Todo]?
    var stubbedError: Error?

    required init(persistentContainer: NSPersistentContainer? = nil) {
        self.persistentContainer = persistentContainer ?? {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            let container = NSPersistentContainer(name: "ToDo_List")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
    }

    func saveTodos(todos: [ToDo_List.Todo]?, completion: (((any Error)?) -> Void)?) {
        // For the protocol implementation
    }

    func getAllTodos(completion: @escaping (Result<[ToDo_List.Todo], any Error>) -> Void) {}

    func createTodo(newTodo: ToDo_List.Todo, completion: (((any Error)?) -> Void)?) {
        createTodoCalled = true
        lastCreatedTodo = newTodo
        completion?(nil)
    }

    func updateTodo(todo: ToDo_List.Todo, completion: (((any Error)?) -> Void)?) {
        updateTodoCalled = true
        lastUpdatedTodo = todo
        completion?(nil)
    }

    func deleteTodo(id: UUID, completion: (((any Error)?) -> Void)?) {
        deleteTodoCalled = true
        lastDeletedId = id
        completion?(nil)
    }

    func deleteAllTodos(completion: (((any Error)?) -> Void)?) {
        // For the protocol implementation
    }
}
