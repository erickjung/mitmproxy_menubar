//
//  TaskManager.swift
//  mitmproxy_menubar
//
//  Created by Erick Jung on 08/04/2019.
//  Copyright © 2019 e7g. All rights reserved.
//

import Foundation

protocol TaskManagerProtocol: class {

    func result(value: String)
}

final class TaskManager {

    weak var delegate: TaskManagerProtocol?

    func execute(launch: String, arg: [String]? = nil, ignoreReturn: Bool = false) {

        self.executeInternal(launch: launch, arg: arg, ignoreReturn: ignoreReturn)
    }

    func executeShell(arg: String) {

        self.executeInternal(launch: "/bin/sh", arg: [arg])
    }

    @discardableResult
    func executeShellSync(arg: String) -> String {

        return self.executeInternalSync(launch: "/bin/sh", arg: [arg])
    }
}

private extension TaskManager {

    func executeInternalSync(launch: String, arg: [String]?) -> String {

        let task = Process()
        task.launchPath = launch

        if let arg = arg {

            task.arguments = arg
        }

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        return output ?? ""
    }

    func executeInternal(launch: String, arg: [String]?, ignoreReturn: Bool = false) {

        DispatchQueue.global(qos: .background).async {

            let task = Process()
            task.launchPath = launch

            if let arg = arg {

                task.arguments = arg
            }

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()

            if ignoreReturn {

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                    self.delegate?.result(value: "")
                }

            } else {

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                    self.delegate?.result(value: output ?? "")
                }
            }

        }
    }
}
