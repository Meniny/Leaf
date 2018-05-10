//
//  LeafURLSession+Stream.swift
//  Leaf
//
//  Created by Elias Abel on 17/3/17.
//
//

import Foundation

#if !os(watchOS)
@available(iOS 9.0, macOS 10.11, *)
extension LeafURLSession {

    open func streamTask(_ service: NetService) -> LeafTask {
        let task = session.streamTask(with: service)
        let streamTask = leafTask(task)
        observe(task, streamTask)
        return streamTask
    }

    open func streamTask(_ domain: String, type: String, name: String = "", port: Int32? = nil) -> LeafTask {
        guard let port = port else {
            return streamTask(NetService(domain: domain, type: type, name: name))
        }
        return streamTask(NetService(domain: domain, type: type, name: name, port: port))
    }

    open func streamTask(_ hostName: String, port: Int) -> LeafTask {
        let task = session.streamTask(withHostName: hostName, port: port)
        let leafStreamTask = leafTask(task)
        observe(task, leafStreamTask)
        return leafStreamTask
    }

}
#endif
