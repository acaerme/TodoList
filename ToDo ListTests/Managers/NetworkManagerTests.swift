import XCTest
@testable import ToDo_List

final class NetworkManagerTests: XCTestCase {
    
    private var sut: NetworkManager!
    private let testUrl = "https://dummyjson.com/todos"
    
    override func setUp() {
        super.setUp()
        sut = NetworkManager(url: testUrl)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_fetchTodos_withValidUrl_returnsNetworkResponse() {
        let expectation = XCTestExpectation(description: "Fetch todos completion")
        
        sut.fetchTodos { result in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response)
                XCTAssertGreaterThan(response.todos.count, 0)
                XCTAssertGreaterThan(response.total, 0)
                XCTAssertGreaterThanOrEqual(response.skip, 0)
                XCTAssertGreaterThan(response.limit, 0)
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func test_fetchTodos_withInvalidUrl_returnsInvalidUrlError() {
        sut = NetworkManager(url: "")
        let expectation = XCTestExpectation(description: "Fetch todos completion")
        
        sut.fetchTodos { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkErrors, .invalidUrl)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func test_fetchTodos_withBadUrl_returnsRequestFailedError() {
        sut = NetworkManager(url: "https://invalid.url.com")
        let expectation = XCTestExpectation(description: "Fetch todos completion")
        
        sut.fetchTodos { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
}
