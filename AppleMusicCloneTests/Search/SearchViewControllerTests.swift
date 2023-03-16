//
//  SearchViewController.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 10.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class SearchViewControllerTests: XCTestCase {
    var vc: SearchViewController?

    override func setUpWithError() throws {
        let tabbar = MainTabBarController()
        tabbar.loadViewIfNeeded()
        vc = (tabbar.viewControllers?.first as? UINavigationController)?.viewControllers.first as? SearchViewController
        vc?.loadViewIfNeeded()
        vc?.table.reloadData()
    }
    
    func testTitleOfNavigationBar() {
        XCTAssertEqual(vc?.navigationItem.title, "Search")
        XCTAssertEqual(vc?.navigationController?.navigationBar.prefersLargeTitles, true)
    }
    
    func testNumberOfSectionIsOne() {
        XCTAssertEqual(vc?.table.numberOfSections, 1)
    }
    
    func testSearchBarInNavigationBar() {
        XCTAssertNotNil(vc?.navigationItem.searchController)
    }
    
    func testSearchControllerDelegate() {
        XCTAssertTrue(vc?.navigationItem.searchController?.searchBar.delegate is SearchViewController)
    }
    
    func testNumberOfRowsInTableView() {
        XCTAssertEqual(vc?.table.numberOfRows(inSection: 0), vc?.numberOfRows)
    }
    
    func testRouterInteractorNotNil() {
        XCTAssertNotNil(vc?.router)
        XCTAssertNotNil(vc?.interactor)
    }
    
    func testTableHeaderViewAndFooterViewIsNotNil() {
        XCTAssertNotNil(vc?.table.tableHeaderView)
        XCTAssertNotNil(vc?.table.tableFooterView)
    }
    
    func testCellInTableViewIsCustomCell() {
        let presenter = SearchPresenter()
        let interactor = MockSearchInteractor()
        vc?.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        vc?.interactor?.makeRequest(request: .getTracks("example"))
        XCTAssertTrue(vc?.table.cellForRow(at: IndexPath(row: 0, section: 0)) is CellForSearchResult)
    }
    
    func testConfigureCell() {
        let presenter = SearchPresenter()
        let interactor = MockSearchInteractor()
        vc?.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = vc
        vc?.interactor?.makeRequest(request: .getTracks("example"))
        let cell = vc?.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? CellForSearchResult
        XCTAssertEqual(cell?.trackName.text, "example1")
        XCTAssertEqual(cell?.albumName.text, "example1 | example1")
    }
    
    func testTableFooterViewIsHidden() {
        let presenter = SearchPresenter()
        presenter.viewController = vc
        presenter.presentData(response: .presentTracks(ResultOfSearch(resultCount: 0, results: [])))
        XCTAssertFalse(vc?.table.tableFooterView?.isHidden ?? true)
    }
    
    func testTableHeaderViewIsNotHidden() {
        vc?.displayData(viewModel: .displayHeaderView)
        XCTAssertTrue(!(vc?.table.tableHeaderView?.isHidden ?? true))
    }
    
    func testTableHeaderViewIsHidden() {
        vc?.displayData(viewModel: .hideHeaderView)
        XCTAssertTrue(vc?.table.tableHeaderView?.isHidden ?? false)
    }
    
    func testDisplayTrack() {
        vc?.displayData(viewModel: .displayTracks(SearchViewModel(cells: [Track(trackName: "example", collectionName: "example", artistName: "example", iconUrlString: "example", audioUrl: "example")])))
        XCTAssertEqual(vc?.table.numberOfRows(inSection: 0), 1)
    }
}
