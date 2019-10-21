//
//  TaskManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation

struct TaskObject {

    let type: TaskType
    let script: String
    let ignoreReturn: Bool
}

enum TaskType {

    case proxyOn
    case proxyOff
    case mitmOn
    case mitmOff
    case ipInfo

    var command: TaskObject {

        switch self {
            case .proxyOn: return TaskObject(type: self, script: "proxy_on", ignoreReturn: true)
            case .proxyOff: return TaskObject(type: self, script: "proxy_off", ignoreReturn: true)
            case .mitmOn: return TaskObject(type: self, script: "mitm_on", ignoreReturn: true)
            case .mitmOff: return TaskObject(type: self, script: "mitm_off", ignoreReturn: true)
            case .ipInfo: return TaskObject(type: self, script: "ip_info", ignoreReturn: false)
        }
    }
}

final class TaskManager {

    static let shared = TaskManager()
    
    func execute(task: TaskType) {
       
        self.executeInternal(task: task)
    }
}

private extension TaskManager {

    @discardableResult
    func executeTask(launch: String, arg: [String]?) -> Pipe {

        let task = Process()
        task.launchPath = launch

        if let arg = arg {

            task.arguments = arg
        }

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        return pipe
    }

    func executeInternal(task: TaskType) {

        DispatchQueue.global(qos: .background).async {

            if let script = Bundle.main.path(forResource: task.command.script, ofType: "sh") {
            
                let pipe = self.executeTask(launch: "/bin/sh", arg: [script, (script as NSString).deletingLastPathComponent])

                if task.command.ignoreReturn {

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        DataStore.state.dispatch(TaskResultAction(task: task))
                    }

                } else {

                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        DataStore.state.dispatch(TaskResultAction(task: task, data: output))
                    }
                }
            }
        }
    }
}
