//
//  SearchModels.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Search {
    enum Model {
        struct Request {
            enum RequestType {
                case getTracks(String)
                case getNextOrPreviousTrack(Int, IndexPath, Bool)
            }
        }
        struct Response {
            enum ResponseType {
                case presentFooterView
                case presentTracks(ResultOfSearch)
                case presentNewTrack(IndexPath)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayFooterView
                case displayTracks(SearchViewModel)
                case displayHeaderView
                case hideHeaderView
                case displayNewTrack(IndexPath)
            }
        }
    }
}

struct SearchViewModel {
    let cells: [Track]
}
