//
//  MockSearchInteractor.swift
//  AppleMusicCloneTests
//
//  Created by 123 on 16.11.2022.
//

import Foundation
@testable import AppleMusicClone

class MockSearchInteractor: SearchInteractor {
    override func makeRequest(request: Search.Model.Request.RequestType) {
        switch request {
        case .getTracks:
            let resultOfSearch = ResultOfSearch(resultCount: 1, results: [
                Track(trackName: "example1", collectionName: "example1", artistName: "example1", iconUrlString: "example1", audioUrl: "example1"),
                Track(trackName: "example2", collectionName: "example2", artistName: "example2", iconUrlString: "example2", audioUrl: "example2")])
            presenter?.presentData(response: .presentTracks(resultOfSearch))
            presenter?.presentData(response: .presentFooterView)
        case .getNextOrPreviousTrack(let count, let currentIndexPath, let isForward):
            var nextIndexPath: IndexPath!
            if isForward {
                nextIndexPath = IndexPath(row: (currentIndexPath.row + 1) % count, section: 0)
            } else {
                nextIndexPath = IndexPath(row: (currentIndexPath.row - 1 + count) % count , section: 0)
            }
            presenter?.presentData(response: .presentNewTrack(nextIndexPath))
        }
    }
}
