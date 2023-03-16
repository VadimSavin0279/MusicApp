//
//  SearchPresenterTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 11.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class SearchPresenterTests: XCTestCase {
    
    let sut = SearchPresenter()
    let searchVc = SearchViewController()
    let mainTabBar = MainTabBarController()

    override func setUpWithError() throws {
        searchVc.loadViewIfNeeded()
        mainTabBar.loadViewIfNeeded()
    }
    
    func testViewControllerNotNil() {
        XCTAssertNotNil(((searchVc.interactor as? SearchInteractor)?.presenter as? SearchPresenter)?.viewController)
    }
    
    func testDataBinding() {
        sut.viewController = searchVc
        sut.presentData(response: .presentTracks(ResultOfSearch(resultCount: 1, results: [Track(trackName: "", collectionName: "", artistName: "", iconUrlString: "", audioUrl: "")])))
        XCTAssertEqual(searchVc.table.numberOfRows(inSection: 0), 1)
        XCTAssertTrue(searchVc.table.tableHeaderView?.isHidden ?? false)
    }
    
    func testDisplayNextTrack() {
        mainTabBar.loadViewIfNeeded()
        mainTabBar.searchViewController.loadViewIfNeeded()
        sut.viewController = mainTabBar.searchViewController
        mainTabBar.searchViewController.interactor?.makeRequest(request: .getTracks("example"))
        sut.presentData(response: .presentTracks(ResultOfSearch(resultCount: 1, results: [
            Track(trackName: "example1", collectionName: "example1", artistName: "example1", iconUrlString: "example1", audioUrl: "example1"),
            Track(trackName: "example2", collectionName: "example2", artistName: "example2", iconUrlString: "example2", audioUrl: "example2")])))
        mainTabBar.searchViewController.table.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        sut.presentData(response: .presentNewTrack(IndexPath(row: 1, section: 0)))
        XCTAssertEqual(mainTabBar.trackView.trackNameLabel.text, "example2")
    }
}
