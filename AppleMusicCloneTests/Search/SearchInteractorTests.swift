//
//  SearchInteractorTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 10.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class SearchInteractorTests: XCTestCase {
    
    let sut = MockSearchInteractor()
    let searchVc = SearchViewController()
    let mainTabBar = MainTabBarController()
    
    override func setUpWithError() throws {
        searchVc.loadViewIfNeeded()
        searchVc.transitionDelegate?.trackView.layoutIfNeeded()
    }
    
    func testRequestFromInteractorForSearch() {
        let presenter = SearchPresenter()
        searchVc.interactor = sut
        sut.presenter = presenter
        presenter.viewController = searchVc
        searchVc.interactor?.makeRequest(request: .getTracks("example"))
        XCTAssertEqual(searchVc.numberOfRows, 2)
    }
    
    func testPresenterNotNil() {
        XCTAssertNotNil((searchVc.interactor as? SearchInteractor)?.presenter)
    }
    
    func testRequestNextTrackAfterLast() {
        prepareDataForTestNextTrack(with: IndexPath(row: 1, section: 0), isForward: true)
        XCTAssertEqual(mainTabBar.searchViewController.transitionDelegate?.trackView.trackNameLabel.text, "example1")
    }

    func testRequestPreviousTrackAfterFirst() {
        prepareDataForTestNextTrack(with: IndexPath(row: 0, section: 0), isForward: false)
        XCTAssertEqual(mainTabBar.searchViewController.transitionDelegate?.trackView.trackNameLabel.text, "example2")
    }
    
    func prepareDataForTestNextTrack(with currentTrack: IndexPath, isForward: Bool) {
        mainTabBar.loadViewIfNeeded()
        mainTabBar.searchViewController.loadViewIfNeeded()
        let presenter = SearchPresenter()
        mainTabBar.searchViewController.interactor = sut
        sut.presenter = presenter
        presenter.viewController = mainTabBar.searchViewController
        mainTabBar.searchViewController.interactor?.makeRequest(request: .getTracks("example"))
        
        mainTabBar.searchViewController.table.selectRow(at: currentTrack, animated: true, scrollPosition: .none)
        sut.makeRequest(request: .getNextOrPreviousTrack(2, currentTrack, isForward))
    }
    
}
