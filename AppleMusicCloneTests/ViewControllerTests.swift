//
//  ViewControllerTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 09.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class ViewControllerTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleOfNavigationBar() {
        let tabbar = MainTabBarController()
        tabbar.loadViewIfNeeded()
        let vc = (tabbar.viewControllers?[1] as? UINavigationController)?.viewControllers.first
        
        XCTAssertEqual(vc?.navigationItem.title, "Library")
        XCTAssertEqual(vc?.navigationController?.navigationBar.prefersLargeTitles, true)
    }
}
