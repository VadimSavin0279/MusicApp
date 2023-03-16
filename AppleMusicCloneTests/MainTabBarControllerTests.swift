//
//  MainTabBarControllerTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 09.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class MainTabBarControllerTests: XCTestCase {

    let tabBar = MainTabBarController()
    var viewControllers: [UIViewController]? {
        return tabBar.viewControllers
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testViewControllersOfTabBarNotNilAndCountIsTwo() {
        XCTAssertNotNil(tabBar.viewControllers)
        XCTAssertEqual(tabBar.viewControllers?.count, 2)
    }
    
    func testTabBarControllersIsNavigationController() {
        tabBarControllersIsNavigationControllerTest(vc: viewControllers?.first)
        tabBarControllersIsNavigationControllerTest(vc: viewControllers?[1])
    }
    
    
    func tabBarControllersIsNavigationControllerTest(vc: UIViewController?) {
        XCTAssertTrue(vc is UINavigationController)
    }
    
    func testRootViewControllerOfNavigationControllerNotNil() {
        rootViewControllerOfNavigationControllerNotNilTest(vc: viewControllers?.first as? UINavigationController)
        rootViewControllerOfNavigationControllerNotNilTest(vc: viewControllers?[1] as? UINavigationController)
    }
    
    func rootViewControllerOfNavigationControllerNotNilTest(vc: UINavigationController?) {
        XCTAssertNotNil(vc?.viewControllers.first)
    }
    
    func testFirstRootVCisSearchViewController() {
        let navVC = viewControllers?.first as? UINavigationController
        let vc = navVC?.viewControllers.first
        XCTAssertTrue(vc is SearchViewController)
    }
    
    func testSecondRootVCisSearchViewController() {
        let navVC = viewControllers?[1] as? UINavigationController
        let vc = navVC?.viewControllers.first
        XCTAssertTrue(vc is ViewController)
    }
    
    func testTitleAndImageOfFirstVC() {
        let navVC = viewControllers?.first
        XCTAssertEqual(navVC?.tabBarItem.image, UIImage(named: "searchIcon"))
    }
    
    func testTitleAndImageOfSecondVC() {
        let navVC = viewControllers?[1]
        XCTAssertEqual(navVC?.tabBarItem.image, UIImage(named: "libraryIcon"))
    }
    
    func testDetailTrackView() {
        for view in tabBar.view.subviews {
            if view is TrackDetailView {
                XCTAssertTrue(view.isEqual(tabBar.trackView))
            }
        }
    }
}
