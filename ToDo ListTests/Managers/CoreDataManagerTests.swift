import XCTest
import CoreData
@testable import ToDo_List

final class CoreDataManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: CoreDataManager!
    private var mockContainer: NSPersistentContainer!
    private let testUUID = UUID()
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        setupMockContainer()
        sut = CoreDataManager(persistentContainer: mockContainer)
    }
    
    override func tearDown() {
        sut = nil
        mockContainer = nil
        super.tearDown()
    }
    
    private func setupMockContainer() {
        mockContainer = NSPersistentContainer(name: "TodoList")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        mockContainer.persistentStoreDescriptions = [description]
        
        let expectation = XCTestExpectation(description: "Load store")
        mockContainer.loadPersistentStores { description, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestTodo() -> Todo {
        return Todo(id: testUUID,
                   title: "Test Todo",
                   description: "Test Description",
                   date: Date(),
                   completed: false)
    }
    
    // MARK: - Tests
    
    func test_saveTodos_createsEntitiesInCoreData() {
        let todos = [createTestTodo()]
        let expectation = XCTestExpectation(description: "Save todos")
        
        sut.saveTodos(todos: todos) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let fetchedTodos):
                XCTAssertEqual(fetchedTodos.count, 1)
                XCTAssertEqual(fetchedTodos.first?.id, self.testUUID)
                XCTAssertEqual(fetchedTodos.first?.title, "Test Todo")
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func test_getAllTodos_whenEmpty_returnsEmptyArray() {
        let expectation = XCTestExpectation(description: "Fetch todos")
        
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertTrue(todos.isEmpty)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getAllTodos_returnsAllSavedTodos() {
        let todo = createTestTodo()
        let saveExpectation = XCTestExpectation(description: "Save todo")
        
        sut.saveTodos(todos: [todo]) { error in
            XCTAssertNil(error)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.id, self.testUUID)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func test_createTodo_savesToCoreData() {
        let todo = createTestTodo()
        let expectation = XCTestExpectation(description: "Create todo")
        
        sut.createTodo(newTodo: todo) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.id, self.testUUID)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func test_updateTodo_modifiesExistingTodo() {
        let todo = createTestTodo()
        let createExpectation = XCTestExpectation(description: "Create todo")
        
        sut.createTodo(newTodo: todo) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: 1.0)
        
        let updatedTodo = Todo(id: testUUID,
                             title: "Updated Title",
                             description: "Updated Description",
                             date: Date(),
                             completed: true)
        
        let updateExpectation = XCTestExpectation(description: "Update todo")
        sut.updateTodo(todo: updatedTodo) { error in
            XCTAssertNil(error)
            updateExpectation.fulfill()
        }
        
        wait(for: [updateExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 1)
                XCTAssertEqual(todos.first?.title, "Updated Title")
                XCTAssertEqual(todos.first?.completed, true)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func test_deleteTodo_removesFromCoreData() {
        let todo = createTestTodo()
        let createExpectation = XCTestExpectation(description: "Create todo")
        
        sut.createTodo(newTodo: todo) { error in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: 1.0)
        
        let deleteExpectation = XCTestExpectation(description: "Delete todo")
        sut.deleteTodo(id: testUUID) { error in
            XCTAssertNil(error)
            deleteExpectation.fulfill()
        }
        
        wait(for: [deleteExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 0)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func test_deleteAllTodos_removesAllTodosFromCoreData() {
        let todos = [
            createTestTodo(),
            Todo(id: UUID(), title: "Test 2", description: "Description 2", date: Date(), completed: false)
        ]
        
        let saveExpectation = XCTestExpectation(description: "Save todos")
        sut.saveTodos(todos: todos) { error in
            XCTAssertNil(error)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        let deleteExpectation = XCTestExpectation(description: "Delete all todos")
        
        // We need to fetch all objects and delete them one by one for in-memory store
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                let group = DispatchGroup()
                todos.forEach { todo in
                    group.enter()
                    self.sut.deleteTodo(id: todo.id) { _ in
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    deleteExpectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
                deleteExpectation.fulfill()
            }
        }
        
        wait(for: [deleteExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch todos")
        sut.getAllTodos { result in
            switch result {
            case .success(let todos):
                XCTAssertEqual(todos.count, 0)
            case .failure(let error):
                XCTFail("Failed to fetch todos: \(error)")
            }
            fetchExpectation.fulfill()
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
}
