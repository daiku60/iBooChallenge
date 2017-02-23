//
//  ImagesListModels.swift
//  iBooChallenge
//
//  Created by Jordi Serra i Font on 19/2/17.
//  Copyright (c) 2017 kudai. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit
import Deferred

struct ImagesList {
    struct Search {
        
        struct Request {
            let searchTerm: String
            let currentPage: Int
            let numberOfItems: Int = 20
        }
        
        struct Response {
            let taskResult: TaskResult<[String: Any]>
        }
        
        enum Presentable {
            case success(ViewModel)
            case error(ErrorViewModel)
            
            struct ViewModel {
                var images: [Image]
                
                struct Image {
                    let identity: String
                    let imageURL: String
                    let title: String
                    var isFavourite: Bool
                }
            }
            
            struct ErrorViewModel {
                let errorTitle: String
                let errorMessage: String
            }
        }
    }
}