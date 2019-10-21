//
//  DataReducer.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 21/10/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation
import ReSwift

func dataReducer(_ action: Action, state: DataState?) -> DataState {

    guard var state = state else {
        return DataState()
    }

    switch action {
        
        case _ as ConfigAction:
        
             TaskManager.shared.execute(task: .ipInfo)
             
        case _ as TouchMitmAction:
        
          if !state.isMitmEnabled {
              
              TaskManager.shared.execute(task: .mitmOn)
              state.isMitmEnabled = true
              
          } else {
          
              TaskManager.shared.execute(task: .mitmOff)
              state.isMitmEnabled = false
          }

        case _ as TouchProxyAction:
        
          if !state.isProxyEnabled {
              
              TaskManager.shared.execute(task: .proxyOn)
              state.isProxyEnabled = true
              
          } else {
          
              TaskManager.shared.execute(task: .proxyOff)
              state.isProxyEnabled = false
          }

        default:
            break
    }

    state.lastAction = action
    
    return state
}


