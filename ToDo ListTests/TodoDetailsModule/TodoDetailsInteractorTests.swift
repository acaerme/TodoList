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
        let expectation = XCTestExpectation(description: "Create todo completion")
        
        sut.handleCreateTodo(title: "", description: "")
        
        // Give time for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.mockCoreDataManager.createTodoCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_handleCreateTodo_withValidFields_createsTodoAndNotifiesPresenter() {
        let expectation = XCTestExpectation(description: "Create todo completion")
        
        sut.handleCreateTodo(title: "Test Title", description: "Test Description")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.mockCoreDataManager.createTodoCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_handleEditTodo_withEmptyFields_deletesTodoAndNotifiesPresenter() {
        let expectation = XCTestExpectation(description: "Delete todo completion")
        let id = UUID()
        
        sut.handleEditTodo(id: id, newTitle: "", newDescription: "",
                          oldTitle: "Old", oldDescription: "Old", completed: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.mockCoreDataManager.deleteTodoCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_handleEditTodo_withUnchangedFields_onlyNotifiesPresenter() {
        let expectation = XCTestExpectation(description: "Update todo completion")
        let title = "Test"
        let description = "Test"
        
        sut.handleEditTodo(id: UUID(), newTitle: title, newDescription: description,
                          oldTitle: title, oldDescription: description, completed: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.mockCoreDataManager.updateTodoCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_handleEditTodo_withChangedFields_updatesTodoAndNotifiesPresenter() {
        let expectation = XCTestExpectation(description: "Update todo completion")
        
        sut.handleEditTodo(id: UUID(), newTitle: "New", newDescription: "New",
                          oldTitle: "Old", oldDescription: "Old", completed: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.mockCoreDataManager.updateTodoCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
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
