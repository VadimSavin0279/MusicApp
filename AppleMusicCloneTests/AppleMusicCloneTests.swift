//
//  AppleMusicCloneTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 08.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class AppleMusicCloneTests: XCTestCase {

    let window = (UIApplication.shared.delegate as? AppDelegate)?.window
    
    var rootVC: UIViewController? {
        return window?.rootViewController
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWindowNotNilAndKey() {
        XCTAssertNotNil(window)
        XCTAssertTrue(window?.isKeyWindow ?? false)
    }
    
    func testRootViewControllerNotNiL() {
        XCTAssertNotNil(rootVC)
    }
    
    func testMainTabBarControllerIsRootViewController() {
        XCTAssertTrue(rootVC is MainTabBarController)
    }
}
