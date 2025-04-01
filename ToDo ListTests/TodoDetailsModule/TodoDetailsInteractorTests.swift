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
        
        // Create test container
        let testContainer = NSPersistentContainer(name: "TodoList")
        testContainer.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        
        // Create mock manager directly
        mockCoreDataManager = MockCoreDataManager(persistentContainer: testContainer)
        
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
}

// MARK: - Mocks

private final class MockTodoDetailsPresenter: TodoDetailsPresenterProtocol {
    var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
    
    func viewDidLoad() {}
    func handleTodo(title: String?, description: String?) {}
}

private final class MockCoreDataManager: CoreDataManager {
    private(set) var createTodoCalled = false
    private(set) var updateTodoCalled = false
    private(set) var deleteTodoCalled = false
    
    override func createTodo(newTodo: Todo, completion: ((Error?) -> Void)? = nil) {
        createTodoCalled = true
        completion?(nil)
    }
    
    override func updateTodo(todo: Todo, completion: ((Error?) -> Void)? = nil) {
        updateTodoCalled = true
        completion?(nil)
    }
    
    override func deleteTodo(id: UUID, completion: ((Error?) -> Void)? = nil) {
        deleteTodoCalled = true
        completion?(nil)
    }
}
