import XCTest
@testable import ToDo_List

final class TodoDetailsRouterTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoDetailsRouter!
    private var mockViewController: MockTodoDetailsViewController!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = TodoDetailsRouter()
        mockViewController = MockTodoDetailsViewController()
        sut.viewController = mockViewController
    }
    
    override func tearDown() {
        sut = nil
        mockViewController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_createModule_withNilTodo_returnsConfiguredViewController() {
        let viewController = TodoDetailsRouter.createModule(with: nil)
        
        XCTAssertNotNil(viewController.presenter)
        XCTAssertNotNil(viewController.presenter?.interactor)
        XCTAssertNotNil(viewController.presenter?.router)
        XCTAssertNotNil(viewController.presenter?.view)
    }
    
    func test_createModule_withTodo_returnsConfiguredViewController() {
        let todo = Todo(id: UUID(), title: "Test", description: "Description", date: Date(), completed: false)
        let viewController = TodoDetailsRouter.createModule(with: todo)
        
        XCTAssertNotNil(viewController.presenter)
        XCTAssertNotNil(viewController.presenter?.interactor)
        XCTAssertNotNil(viewController.presenter?.router)
        XCTAssertNotNil(viewController.presenter?.view)
    }
}

// MARK: - Mocks

private final class MockTodoDetailsViewController: TodoDetailsViewController {
    private(set) var dismissCalled = false
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCalled = true
    }
}
