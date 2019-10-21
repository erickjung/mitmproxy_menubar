//
//  DataActions.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 21/10/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation
import ReSwift

struct ConfigAction: Action {}

struct TouchMitmAction: Action {}

struct TouchProxyAction: Action {}

struct CheckServiceStateAction: Action {}

struct TaskResultAction: Action {

    var task: TaskType
    var data: String? = nil
}
