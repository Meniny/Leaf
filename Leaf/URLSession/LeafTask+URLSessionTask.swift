//
//  LeafTask+URLSessionTask.swift
//  Leaf
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

extension LeafTask {

    public convenience init(_ urlSessionTask: URLSessionTask, request: LeafRequest? = nil, response: LeafResponse? = nil, error: LeafError? = nil) {
        self.init(urlSessionTask.taskIdentifier, request: request, response: response, taskDescription: urlSessionTask.taskDescription, state: LeafState(rawValue: urlSessionTask.state.rawValue) ?? .suspended, error: error, priority: urlSessionTask.priority, task: urlSessionTask)
    }
    
}

extension URLSessionTask: LeafTaskProtocol {}
