import XCTest
@testable import ToDo_List

final class TodoListRouterTests: XCTestCase {

    // MARK: - Properties

    private var sut: TodoListRouter!
    private var mockViewController: MockTodoListViewController!
    private var mockNavigationController: MockNavigationController!
    private var mockPresenter: MockTodoListPresenter!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = TodoListRouter()
        mockViewController = MockTodoListViewController()
        mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [mockViewController]
        sut.viewController = mockViewController

        mockPresenter = MockTodoListPresenter()
        sut.viewController?.presenter = mockPresenter
        mockPresenter.router = sut
    }

    override func tearDown() {
        sut = nil
        mockViewController = nil
        mockNavigationController = nil
        mockPresenter = nil
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
        let expectation = XCTestExpectation(description: "Push view controller")

        mockNavigationController.pushViewControllerClosure = { viewController in
            XCTAssertTrue(viewController is TodoDetailsViewController)
            expectation.fulfill()
        }

        sut.presentTodoDetailsVC(todo: nil)

        wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(mockNavigationController.pushViewControllerCalled)
    }

    func test_presentTodoDetailsVC_withTodo_pushesDetailsViewController() {
        let expectation = XCTestExpectation(description: "Push view controller")
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)

        mockNavigationController.pushViewControllerClosure = { viewController in
            XCTAssertTrue(viewController is TodoDetailsViewController)
            expectation.fulfill()
        }

        sut.presentTodoDetailsVC(todo: todo)

        wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(mockNavigationController.pushViewControllerCalled)
    }

    func test_presentShareSheet_presentsActivityViewController() {
        let expectation = XCTestExpectation(description: "Present activity view controller")
        let testTitle = "Test Title"

        mockViewController.presentCompletion = { viewControllerToPresent in
            guard let activityVC = viewControllerToPresent as? UIActivityViewController else {
                XCTFail("Expected UIActivityViewController")
                return
            }

            guard let activityItems = activityVC.value(forKey: "activityItems") as? [Any] else {
                XCTFail("Failed to get activity items")
                return
            }

            XCTAssertEqual(activityItems.count, 1)
            XCTAssertEqual(activityItems[0] as? String, testTitle)
            expectation.fulfill()
        }

        sut.presentShareSheet(todoTitle: testTitle)

        wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(mockViewController.presentCalled)
    }

    func test_presentAlert_presentsAlertController() {
        let expectation = XCTestExpectation(description: "Present alert controller")
        let alert = UIAlertController(title: "Error", message: "Test Message", preferredStyle: .alert)

        mockViewController.presentCompletion = { viewControllerToPresent in
            guard let alertVC = viewControllerToPresent as? UIAlertController else {
                XCTFail("Expected UIAlertController")
                return
            }

            XCTAssertEqual(alertVC.title, "Error")
            XCTAssertEqual(alertVC.message, "Test Message")
            expectation.fulfill()
        }

        sut.presentAlert(alert: alert)

        wait(for: [expectation], timeout: 3.0)
        XCTAssertTrue(mockViewController.presentCalled)
    }
}

// MARK: - Mocks

private final class MockTodoListViewController: TodoListViewController {
    private(set) var presentCalled = false
    private(set) var lastPresentedViewController: UIViewController?
    var presentCompletion: ((UIViewController) -> Void)?

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        presentCalled = true
        lastPresentedViewController = viewControllerToPresent
        presentCompletion?(viewControllerToPresent)
        super.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

private final class MockNavigationController: UINavigationController {
    private(set) var pushViewControllerCalled = false
    private(set) var pushedViewController: UIViewController?
    var pushViewControllerClosure: ((UIViewController) -> Void)?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCalled = true
        pushedViewController = viewController
        pushViewControllerClosure?(viewController)
        super.pushViewController(viewController, animated: animated)
    }
}

private final class MockTodoListPresenter: TodoListPresenterProtocol {
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?

    var presentAlertCalled = false

    func viewDidLoad() {}
    func updateTodosList(with result: Result<[Todo], Error>) {}
    func didSelectTodo(todo: Todo) {}
    func newTodoButtonTapped() {}
    func toggleTodo(todo: Todo) {}
    func searchForTodos(with searchText: String) {}
    func editButtonTapped(todo: Todo?) {}
    func deleteButtonTapped(todo: Todo?) {}
    func deleteAllTodosButtonTapped() {
        presentAlertCalled = true
    }
    func shareButtonTapped(todo: Todo) {}
    func contextMenuConfiguration(for todo: Todo, at indexPath: IndexPath) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration()
    }
    func presentStandardErrorAlert() {}
    func getTaskCountText(for count: Int) -> String { return "" }
}
