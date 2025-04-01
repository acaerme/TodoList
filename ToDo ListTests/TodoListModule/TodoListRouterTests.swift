import XCTest
@testable import ToDo_List

final class TodoListRouterTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoListRouter!
    private var mockViewController: MockTodoListViewController!
    private var mockNavigationController: MockNavigationController!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = TodoListRouter()
        mockViewController = MockTodoListViewController()
        mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [mockViewController]
        sut.viewController = mockViewController
    }
    
    override func tearDown() {
        sut = nil
        mockViewController = nil
        mockNavigationController = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_createModule_returnsConfiguredViewController() {
        let viewController = TodoListRouter.createModule()
        
        XCTAssertNotNil(viewController.presenter)
        XCTAssertNotNil(viewController.presenter?.interactor)
        XCTAssertNotNil(viewController.presenter?.router)
        XCTAssertNotNil(viewController.presenter?.view)
        XCTAssertTrue(viewController.presenter?.view === viewController)
    }
    
    func test_presentTodoDetailsVC_withNilTodo_pushesDetailsViewController() {
        sut.presentTodoDetailsVC(todo: nil)
        
        XCTAssertTrue(mockNavigationController.pushViewControllerCalled)
        XCTAssertTrue(mockNavigationController.pushedViewController is TodoDetailsViewController)
    }
    
    func test_presentTodoDetailsVC_withTodo_pushesDetailsViewController() {
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        
        sut.presentTodoDetailsVC(todo: todo)
        
        XCTAssertTrue(mockNavigationController.pushViewControllerCalled)
        XCTAssertTrue(mockNavigationController.pushedViewController is TodoDetailsViewController)
    }
    
    func test_presentShareSheet_presentsActivityViewController() {
        let testTitle = "Test Title"
        sut.presentShareSheet(todoTitle: testTitle)
        
        XCTAssertTrue(mockViewController.presentCalled)
        
        guard let activityVC = mockViewController.lastPresentedViewController as? UIActivityViewController else {
            XCTFail("Expected UIActivityViewController")
            return
        }
        
        guard let activityItems = activityVC.value(forKey: "activityItems") as? [Any] else {
            XCTFail("Failed to get activity items")
            return
        }
        
        XCTAssertEqual(activityItems.count, 1)
        XCTAssertEqual(activityItems[0] as? String, testTitle)
    }
    
    func test_presentErrorAlert_presentsAlertController() {
        let alert = UIAlertController(title: "Error", message: "Test Message", preferredStyle: .alert)
        
        sut.presentErrorAlert(alert: alert)
        
        XCTAssertTrue(mockViewController.presentCalled)
        XCTAssertTrue(mockViewController.lastPresentedViewController is UIAlertController)
        
        let alertVC = mockViewController.lastPresentedViewController as? UIAlertController
        XCTAssertEqual(alertVC?.title, "Error")
        XCTAssertEqual(alertVC?.message, "Test Message")
    }
    
    func test_presentDeleteAllTodosAlert_presentsAlertController() {
        let alert = UIAlertController(title: "Delete", message: "Delete all?", preferredStyle: .alert)
        
        sut.presentDeleteAllTodosAlert(alert: alert)
        
        XCTAssertTrue(mockViewController.presentCalled)
        XCTAssertTrue(mockViewController.lastPresentedViewController is UIAlertController)
        
        let alertVC = mockViewController.lastPresentedViewController as? UIAlertController
        XCTAssertEqual(alertVC?.title, "Delete")
        XCTAssertEqual(alertVC?.message, "Delete all?")
    }
}

// MARK: - Mocks

private final class MockTodoListViewController: TodoListViewController {
    private(set) var presentCalled = false
    private(set) var lastPresentedViewController: UIViewController?
    
    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        presentCalled = true
        lastPresentedViewController = viewControllerToPresent
        super.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

private final class MockNavigationController: UINavigationController {
    private(set) var pushViewControllerCalled = false
    private(set) var pushedViewController: UIViewController?
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCalled = true
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}
