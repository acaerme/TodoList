import XCTest
@testable import ToDo_List

final class TodoDetailsPresenterTests: XCTestCase {
    
    // MARK: - Properties
    
    private var sut: TodoDetailsPresenter!
    private var mockView: MockTodoDetailsView!
    private var mockInteractor: MockTodoDetailsInteractor!
    private var mockRouter: MockTodoDetailsRouter!
    private var mockTodo: Todo!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockView = MockTodoDetailsView()
        mockInteractor = MockTodoDetailsInteractor()
        mockRouter = MockTodoDetailsRouter()
        mockTodo = Todo(id: UUID(),
                       title: "Test Title",
                       description: "Test Description",
                       date: Date(),
                       completed: false)
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        mockTodo = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_viewDidLoad_withExistingTodo_configuresViewCorrectly() {
        sut = TodoDetailsPresenter(todo: mockTodo)
        sut.view = mockView
        
        sut.viewDidLoad()
        
        XCTAssertTrue(mockView.configureContentCalled)
        XCTAssertEqual(mockView.configuredTitle, mockTodo.title)
        XCTAssertEqual(mockView.configuredDescription, mockTodo.description)
        XCTAssertFalse(mockView.makeFirstResponderCalled)
    }
    
    func test_viewDidLoad_withNoTodo_makesViewFirstResponder() {
        sut = TodoDetailsPresenter(todo: nil)
        sut.view = mockView
        
        sut.viewDidLoad()
        
        XCTAssertTrue(mockView.configureContentCalled)
        XCTAssertTrue(mockView.makeFirstResponderCalled)
        XCTAssertEqual(mockView.configuredTitle, "")
        XCTAssertEqual(mockView.configuredDescription, "")
    }
    
    func test_handleTodo_inCreateMode_callsInteractorCreateMethod() {
        sut = TodoDetailsPresenter(todo: nil)
        sut.interactor = mockInteractor
        
        sut.handleTodo(title: "New Title", description: "New Description")
        
        XCTAssertTrue(mockInteractor.handleCreateTodoCalled)
        XCTAssertEqual(mockInteractor.createdTitle, "New Title")
        XCTAssertEqual(mockInteractor.createdDescription, "New Description")
    }
    
    func test_handleTodo_inEditMode_callsInteractorEditMethod() {
        sut = TodoDetailsPresenter(todo: mockTodo)
        sut.interactor = mockInteractor
        
        sut.handleTodo(title: "Updated Title", description: "Updated Description")
        
        XCTAssertTrue(mockInteractor.handleEditTodoCalled)
        XCTAssertEqual(mockInteractor.editedNewTitle, "Updated Title")
        XCTAssertEqual(mockInteractor.editedNewDescription, "Updated Description")
    }
    
    func test_handleTodo_withNilValues_usesEmptyStrings() {
        sut = TodoDetailsPresenter(todo: nil)
        sut.interactor = mockInteractor
        
        sut.handleTodo(title: nil, description: nil)
        
        XCTAssertTrue(mockInteractor.handleCreateTodoCalled)
        XCTAssertEqual(mockInteractor.createdTitle, "")
        XCTAssertEqual(mockInteractor.createdDescription, "")
    }
}

// MARK: - Mocks

private final class MockTodoDetailsView: TodoDetailsViewProtocol {
    var presenter: TodoDetailsPresenterProtocol?
    
    private(set) var configureContentCalled = false
    private(set) var makeFirstResponderCalled = false
    private(set) var configuredDate = ""
    private(set) var configuredTitle = ""
    private(set) var configuredDescription = ""
    
    func configureContent(date: String, title: String, description: String) {
        configureContentCalled = true
        configuredDate = date
        configuredTitle = title
        configuredDescription = description
    }
    
    func makeTitleTextFieldFirstResponder() {
        makeFirstResponderCalled = true
    }
}

private final class MockTodoDetailsInteractor: TodoDetailsInteractorProtocol {
    var presenter: TodoDetailsPresenterProtocol?
    
    private(set) var handleCreateTodoCalled = false
    private(set) var handleEditTodoCalled = false
    private(set) var createdTitle = ""
    private(set) var createdDescription = ""
    private(set) var editedNewTitle = ""
    private(set) var editedNewDescription = ""
    
    func handleCreateTodo(title: String, description: String) {
        handleCreateTodoCalled = true
        createdTitle = title
        createdDescription = description
    }
    
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                       oldTitle: String, oldDescription: String, completed: Bool) {
        handleEditTodoCalled = true
        editedNewTitle = newTitle
        editedNewDescription = newDescription
    }
}

private final class MockTodoDetailsRouter: TodoDetailsRouterProtocol {
    var viewController: TodoDetailsViewController?
    
    static func createModule(with todo: Todo?) -> TodoDetailsViewController {
        return TodoDetailsViewController()
    }
}
