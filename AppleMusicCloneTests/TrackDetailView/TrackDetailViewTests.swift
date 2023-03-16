//
//  TrackDetailViewTests.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 16.11.2022.
//

import XCTest
@testable import AppleMusicClone

final class TrackDetailViewTests: XCTestCase {
    let mainTabBar = MainTabBarController()
    var sut: TrackDetailView {
        return mainTabBar.trackView
    }

    override func setUpWithError() throws {
        mainTabBar.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDelegatesNotNil() {
        XCTAssertNotNil(sut.delegate)
        XCTAssertNotNil(sut.transitionDelegate)
    }
    
    func testSetupFnction() {
        sut.setup(viewModel: Track(trackName: "example", collectionName: "example", artistName: "example", iconUrlString: "example", audioUrl: "example"))
        XCTAssertEqual(sut.trackNameLabel.text, "example")
        XCTAssertEqual(sut.authorNameLabel.text, "example | example")
        XCTAssertEqual(sut.currentTimeLabel.text, "00:00")
        XCTAssertEqual(sut.durationTimeLabel.text, "--:--")
    }
    
    func testSetupMiniTrackView() {
        sut.setup(viewModel: Track(trackName: "example", collectionName: "example", artistName: "example", iconUrlString: "example", audioUrl: "example"))
        
        XCTAssertEqual(sut.miniTrackNameLabel.text, "example")
        XCTAssertEqual(sut.miniAuthorNameLabel.text, "example | example")
    }

}
