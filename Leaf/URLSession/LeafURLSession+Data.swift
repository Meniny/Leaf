//
//  LeafURLSession+Data.swift
//  Leaf
//
//  Created by Elias Abel on 17/3/17.
//
//

import Foundation

extension LeafURLSession {

    open func dataTask(_ request: LeafRequest) -> LeafTask {
        var leafDataTask: LeafTask?
        let task = session.dataTask(with: urlRequest(request)) { [weak self] (data, response, error) in
            let leafResponse = self?.leafResponse(response, leafDataTask, data)
            let leafError = self?.leafError(error, data, response)
            self?.process(leafDataTask, leafResponse, leafError)
        }
        leafDataTask = leafTask(task, request)
        observe(task, leafDataTask)
        return leafDataTask!
    }

    open func dataTask(_ request: URLRequest) throws -> LeafTask {
        guard let leafRequest = request.leafRequest else {
            throw leafError(URLError(.badURL))!
        }
        return dataTask(leafRequest)
    }

    open func dataTask(_ url: URL, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> LeafTask {
        return dataTask(leafRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func dataTask(_ urlString: String, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> LeafTask {
        guard let url = URL(string: urlString) else {
            throw leafError(URLError(.badURL))!
        }
        return dataTask(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
