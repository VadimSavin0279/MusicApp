//
//  SearchProviderTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 10.11.2022.
//

import XCTest
@testable import AppleMusicClone
import Alamofire

final class SearchProviderTests: XCTestCase {
    
    let sut = SearchProvider.getTrack("example")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBaseUrlOfProvider() {
        switch sut {
        case .getTrack:
            XCTAssertEqual(sut.baseURL, "https://itunes.apple.com")
        }
    }
    
    func testPathOfProvider() {
        switch sut {
        case .getTrack:
            XCTAssertEqual(sut.path, "/search")
        }
    }
    
    func testMethofOfProvider() {
        switch sut {
        case .getTrack:
            XCTAssertEqual(sut.method.rawValue, "GET")
        }
    }
    
    func testParamsOfProvider() {
        switch sut {
        case .getTrack(let textForSearching):
            XCTAssertEqual(sut.params["term"] as? String, textForSearching)
        }
    }
    
    func testParsingInModel() {
        let exp = self.expectation(description: "myExpectation")
        let manager = APIManager()
        var resultOfSearch: ResultOfSearch?
        manager.sendRequest(with: SearchProvider.getTrack("example"), decodeType: ResultOfSearch.self) { response in
            switch response {
            case .success(let result):
                resultOfSearch = result
                exp.fulfill()
            case .failure:
                break
            }
        }
        waitForExpectations(timeout: 10) { _ in
            XCTAssertNotNil(resultOfSearch)
            XCTAssertFalse(resultOfSearch?.results.isEmpty ?? true)
        }
    }

}
