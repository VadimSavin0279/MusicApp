//
//  SearchInteractor.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var presenter: SearchPresentationLogic?
    var service: SearchService = SearchService()
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        switch request {
        case .getTracks(let searchText):
            if !searchText.isEmpty {
                service.fetchTracks(searchText: searchText) { [weak self] result in
                    self?.presenter?.presentData(response: .presentTracks(result))
                } completionForError: { [weak self] in
                    self?.presenter?.presentData(response: .presentTracks(ResultOfSearch(resultCount: 0, results: [])))
                }
            }
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
