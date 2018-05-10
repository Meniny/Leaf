//
//  LeafURLSession+Upload.swift
//  Leaf
//
//  Created by Elias Abel on 17/3/17.
//
//

extension LeafURLSession {

    open func uploadTask(_ streamedRequest: LeafRequest) -> LeafTask {
        let task = session.uploadTask(withStreamedRequest: urlRequest(streamedRequest))
        let leafUploadTask = leafTask(task, streamedRequest)
        observe(task, leafUploadTask)
        return leafUploadTask
    }

    open func uploadTask(_ streamedRequest: URLRequest) throws -> LeafTask {
        guard let leafRequest = streamedRequest.leafRequest else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(leafRequest)
    }

    open func uploadTask(_ streamedURL: URL, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> LeafTask {
        return uploadTask(leafRequest(streamedURL, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func uploadTask(_ streamedURLString: String, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> LeafTask {
        guard let url = URL(string: streamedURLString) else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func uploadTask(_ request: LeafRequest, data: Data) -> LeafTask {
        var leafUploadTask: LeafTask?
        let task = session.uploadTask(with: urlRequest(request), from: data) { [weak self] (data, response, error) in
            let leafResponse = self?.leafResponse(response, leafUploadTask, data)
            let leafError = self?.leafError(error, data, response)
            self?.process(leafUploadTask, leafResponse, leafError)
        }
        leafUploadTask = leafTask(task, request)
        observe(task, leafUploadTask)
        return leafUploadTask!
    }

    open func uploadTask(_ request: URLRequest, data: Data) throws -> LeafTask {
        guard let leafRequest = request.leafRequest else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(leafRequest, data: data)
    }

    open func uploadTask(_ url: URL, data: Data, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> LeafTask {
        return uploadTask(leafRequest(url, cache: cachePolicy, timeout: timeoutInterval), data: data)
    }

    open func uploadTask(_ urlString: String, data: Data, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> LeafTask {
        guard let url = URL(string: urlString) else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(url, data: data, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

    open func uploadTask(_ request: LeafRequest, fileURL: URL) -> LeafTask {
        var leafUploadTask: LeafTask?
        let task = session.uploadTask(with: urlRequest(request), fromFile: fileURL) { [weak self] (data, response, error) in
            let leafResponse = self?.leafResponse(response, leafUploadTask, data)
            let leafError = self?.leafError(error, data, response)
            self?.process(leafUploadTask, leafResponse, leafError)
        }
        leafUploadTask = leafTask(task, request)
        observe(task, leafUploadTask)
        return leafUploadTask!
    }

    open func uploadTask(_ request: URLRequest, fileURL: URL) throws -> LeafTask {
        guard let leafRequest = request.leafRequest else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(leafRequest, fileURL: fileURL)
    }

    open func uploadTask(_ url: URL, fileURL: URL, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> LeafTask {
        return uploadTask(leafRequest(url, cache: cachePolicy, timeout: timeoutInterval), fileURL: fileURL)
    }

    open func uploadTask(_ urlString: String, fileURL: URL, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> LeafTask {
        guard let url = URL(string: urlString) else {
            throw leafError(URLError(.badURL))!
        }
        return uploadTask(url, fileURL: fileURL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
