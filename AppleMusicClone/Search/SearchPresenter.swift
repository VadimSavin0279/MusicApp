//
//  SearchPresenter.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {
        case .presentTracks(let result):
            if result.results.isEmpty {
                viewController?.displayData(viewModel: .displayHeaderView)
            } else {
                viewController?.displayData(viewModel: .hideHeaderView)
            }
            viewController?.displayData(viewModel: .displayTracks(SearchViewModel(cells: result.results)))
        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
        case .presentNewTrack(let newIndexPath):
            viewController?.displayData(viewModel: .displayNewTrack(newIndexPath))
        }
    }
}
