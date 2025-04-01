import XCTest
@testable import ToDo_List

final class TodoListPresenterTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoListPresenter!
    private var mockView: MockTodoListView!
    private var mockInteractor: MockTodoListInteractor!
    private var mockRouter: MockTodoListRouter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = TodoListPresenter()
        mockView = MockTodoListView()
        mockInteractor = MockTodoListInteractor()
        mockRouter = MockTodoListRouter()
        
        sut.view = mockView
        sut.interactor = mockInteractor
        sut.router = mockRouter
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }
    
    // MARK: - Lifecycle Tests
    
    func test_viewDidLoad_callsFetchTodos() {
        sut.viewDidLoad()
        
        XCTAssertTrue(mockInteractor.fetchTodosCalled)
    }
    
    // MARK: - Update List Tests
    
    func test_updateTodosList_withSuccess_updatesViewWithCorrectViewModel() {
        let todos = [
            Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        ]
        
        sut.updateTodosList(with: .success(todos))
        
        XCTAssertEqual(mockView.lastViewModel?.todos.count, 1)
        XCTAssertEqual(mockView.lastViewModel?.taskCountText, "1 задача")
        XCTAssertTrue(mockView.lastViewModel?.isNoTodosHidden ?? false)
        XCTAssertFalse(mockView.lastViewModel?.isTableViewHidden ?? true)
        XCTAssertFalse(mockView.lastViewModel?.isTaskCountLabelHidden ?? true)
    }
    
    func test_updateTodosList_withFailure_presentsErrorAlert() {
        sut.updateTodosList(with: .failure(NSError(domain: "", code: -1)))
        
        XCTAssertTrue(mockRouter.presentErrorAlertCalled)
    }
    
    // MARK: - User Interaction Tests
    
    func test_didSelectTodo_callsRouterToPresent() {
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        
        sut.didSelectTodo(todo: todo)
        
        XCTAssertTrue(mockRouter.presentTodoDetailsVCCalled)
        XCTAssertEqual(mockRouter.lastPresentedTodo?.id, todo.id)
    }
    
    func test_newTodoButtonTapped_callsRouterWithNilTodo() {
        sut.newTodoButtonTapped()
        
        XCTAssertTrue(mockRouter.presentTodoDetailsVCCalled)
        XCTAssertNil(mockRouter.lastPresentedTodo)
    }
    
    func test_toggleTodoCompletion_callsInteractorToUpdate() {
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        
        sut.toggleTodoCompletion(for: todo)
        
        XCTAssertTrue(mockInteractor.updateTodoCalled)
        XCTAssertEqual(mockInteractor.lastUpdatedTodo?.id, todo.id)
    }
    
    func test_searchForTodos_callsInteractorToFilter() {
        sut.searchForTodos(with: "test")
        
        XCTAssertTrue(mockInteractor.filterTodosCalled)
        XCTAssertEqual(mockInteractor.lastSearchText, "test")
    }
    
    func test_deleteButtonTapped_callsInteractorToDelete() {
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        
        sut.deleteButtonTapped(todo: todo)
        
        XCTAssertTrue(mockInteractor.deleteCalled)
        XCTAssertEqual(mockInteractor.lastDeletedId, todo.id)
    }
    
    func test_shareButtonTapped_callsRouterToPresent() {
        let todo = Todo(id: UUID(), title: "Test", description: "Test", date: Date(), completed: false)
        
        sut.shareButtonTapped(todo: todo)
        
        XCTAssertTrue(mockRouter.presentShareSheetCalled)
        XCTAssertEqual(mockRouter.lastSharedTitle, "Test")
    }
    
    func test_deleteAllTodosButtonTapped_presentsDeleteAlert() {
        sut.deleteAllTodosButtonTapped()
        XCTAssertTrue(mockRouter.presentErrorAlertCalled)
    }
    // MARK: - Helper Method Tests
    
    func test_getTaskCountText_returnsCorrectForm() {
        XCTAssertEqual(sut.getTaskCountText(for: 1), "1 задача")
        XCTAssertEqual(sut.getTaskCountText(for: 2), "2 задачи")
        XCTAssertEqual(sut.getTaskCountText(for: 5), "5 задач")
        XCTAssertEqual(sut.getTaskCountText(for: 11), "11 задач")
        XCTAssertEqual(sut.getTaskCountText(for: 21), "21 задача")
    }
}

// MARK: - Mocks

private final class MockTodoListView: TodoListViewProtocol {
    var presenter: TodoListPresenterProtocol?
    private(set) var lastViewModel: TodoListViewModel?
    
    func update(with viewModel: TodoListViewModel) {
        lastViewModel = viewModel
    }
}

private final class MockTodoListInteractor: TodoListInteractorProtocol {
    var presenter: TodoListPresenterProtocol?
    
    private(set) var fetchTodosCalled = false
    private(set) var filterTodosCalled = false
    private(set) var updateTodoCalled = false
    private(set) var deleteCalled = false
    private(set) var deleteAllTodosCalled = false
    
    private(set) var lastSearchText: String?
    private(set) var lastUpdatedTodo: Todo?
    private(set) var lastDeletedId: UUID?
    
    func fetchTodos() {
        fetchTodosCalled = true
    }
    
    func filterTodos(with searchText: String, completion: @escaping (([Todo]) -> Void)) {
        filterTodosCalled = true
        lastSearchText = searchText
        completion([]) // Return empty array for testing
    }
    
    func updateTodo(updatedTodo: Todo) {
        updateTodoCalled = true
        lastUpdatedTodo = updatedTodo
    }
    
    func delete(id: UUID) {
        deleteCalled = true
        lastDeletedId = id
    }
    
    func deleteAllTodos() {
        deleteAllTodosCalled = true
    }
}

private final class MockTodoListRouter: TodoListRouterProtocol {
    var viewController: TodoListViewController?
    
    private(set) var presentTodoDetailsVCCalled = false
    private(set) var presentShareSheetCalled = false
    private(set) var presentErrorAlertCalled = false
    private(set) var presentDeleteAllTodosAlertCalled = false
    
    private(set) var lastPresentedTodo: Todo?
    private(set) var lastSharedTitle: String?
    
    static func createModule() -> TodoListViewController {
        return TodoListViewController()
    }
    
    func presentTodoDetailsVC(todo: Todo?) {
        presentTodoDetailsVCCalled = true
        lastPresentedTodo = todo
    }
    
    func presentShareSheet(todoTitle: String) {
        presentShareSheetCalled = true
        lastSharedTitle = todoTitle
    }
    
    func presentErrorAlert(alert: UIAlertController) {
        presentErrorAlertCalled = true
    }
    
    func presentDeleteAllTodosAlert(alert: UIAlertController) {
        presentDeleteAllTodosAlertCalled = true
    }
}
