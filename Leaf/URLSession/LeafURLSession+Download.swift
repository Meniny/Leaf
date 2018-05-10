//
//  LeafURLSession+Download.swift
//  Leaf
//
//  Created by Elias Abel on 17/3/17.
//
//

extension LeafURLSession {

    open func downloadTask(_ resumeData: Data) -> LeafTask {
        var leafDownloadTask: LeafTask?
        let task = session.downloadTask(withResumeData: resumeData) { [weak self] (url, response, error) in
            let leafResponse = self?.leafResponse(response, leafDownloadTask, url)
            let leafError = self?.leafError(error, url, response)
            self?.process(leafDownloadTask, leafResponse, leafError)
        }
        leafDownloadTask = leafTask(task)
        observe(task, leafDownloadTask)
        return leafDownloadTask!
    }

    open func downloadTask(_ request: LeafRequest) -> LeafTask {
        var leafDownloadTask: LeafTask?
        let task = session.downloadTask(with: urlRequest(request)) { [weak self] (url, response, error) in
            let leafResponse = self?.leafResponse(response, leafDownloadTask, url)
            let leafError = self?.leafError(error, url, response)
            self?.process(leafDownloadTask, leafResponse, leafError)
        }
        leafDownloadTask = leafTask(task, request)
        observe(task, leafDownloadTask)
        return leafDownloadTask!
    }

    open func downloadTask(_ request: URLRequest) throws -> LeafTask {
        guard let leafRequest = request.leafRequest else {
            throw leafError(URLError(.badURL))!
        }
        return downloadTask(leafRequest)
    }

    open func downloadTask(_ url: URL, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) -> LeafTask {
        return downloadTask(leafRequest(url, cache: cachePolicy, timeout: timeoutInterval))
    }

    open func downloadTask(_ urlString: String, cachePolicy: LeafRequest.LeafCachePolicy? = nil, timeoutInterval: TimeInterval? = nil) throws -> LeafTask {
        guard let url = URL(string: urlString) else {
            throw leafError(URLError(.badURL))!
        }
        return downloadTask(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }

}
