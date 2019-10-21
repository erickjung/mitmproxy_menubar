//
//  DataStore.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 21/10/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation
import ReSwift

private let logging: Middleware<StateType> = { dispatch, getState in
    return { next in
        return { action in
            print("> \(action)")
            return next(action)
        }
    }
}

final class DataStore {
    
    static let state = Store<DataState>(reducer: dataReducer, state: nil, middleware: [ logging ])
}
