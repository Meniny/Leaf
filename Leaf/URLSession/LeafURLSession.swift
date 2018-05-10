//
//  LeafURLSession.swift
//  Leaf
//
//  Created by Elias Abel on 16/3/17.
//
//

import Foundation

open class LeafURLSession: Leafable {
    
    open static var shared: Leafable {
        return self.default
    }

    open static let `default` = LeafURLSession.init(URLSession.shared)

    open static let defaultCache: URLCache = {
        let defaultMemoryCapacity = 4 * 1024 * 1024
        let defaultDiskCapacity = 5 * defaultMemoryCapacity
        let cachesDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let cacheURL = cachesDirectoryURL?.appendingPathComponent(String(describing: LeafURLSession.self))
        var defaultDiskPath = cacheURL?.path
        #if os(OSX)
        defaultDiskPath = cacheURL?.absoluteString
        #endif
        return URLCache(memoryCapacity: defaultMemoryCapacity, diskCapacity: defaultDiskCapacity, diskPath: defaultDiskPath)
    }()

    open private(set) var session: URLSession!

    open var delegate: URLSessionDelegate? { return session.delegate }

    open var delegateQueue: OperationQueue { return session.delegateQueue }

    open var configuration: URLSessionConfiguration { return session.configuration }

    open var sessionDescription: String? {
        get {
            return session.sessionDescription
        }
        set {
            session.sessionDescription = newValue
        }
    }

    open var requestInterceptors = [RequestInterceptor]()

    open var responseInterceptors = [ResponseInterceptor]()

    open var retryClosure: LeafTask.RetryClosure?

    open private(set) var authChallenge: ((URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) -> Swift.Void)?

    open private(set) var serverTrust = [String: LeafServerTrust]()

    fileprivate final var taskObserver: LeafURLSessionTaskObserver? = LeafURLSessionTaskObserver()

    public convenience init() {
        let defaultConfiguration = URLSessionConfiguration.default
        defaultConfiguration.urlCache = LeafURLSession.defaultCache
        self.init(defaultConfiguration)
    }

    public init(_ urlSession: URLSession) {
        session = urlSession
    }

    public init(_ configuration: URLSessionConfiguration, delegateQueue: OperationQueue? = nil, delegate: URLSessionDelegate? = nil) {
        let sessionDelegate = delegate ?? LeafURLSessionDelegate(self)
        session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: delegateQueue)
    }

    public init(_ configuration: URLSessionConfiguration, challengeQueue: OperationQueue? = nil, authenticationChallenge: @escaping (URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) -> Swift.Void) {
        session = URLSession(configuration: configuration, delegate: LeafURLSessionDelegate(self), delegateQueue: challengeQueue)
        authChallenge = authenticationChallenge
    }

    public init(_ configuration: URLSessionConfiguration, challengeQueue: OperationQueue? = nil, serverTrustPolicies: [String: LeafServerTrust]) {
        session = URLSession(configuration: configuration, delegate: LeafURLSessionDelegate(self), delegateQueue: challengeQueue)
        serverTrust = serverTrustPolicies
    }

    open func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor) {
        requestInterceptors.append(interceptor)
    }

    open func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor) {
        responseInterceptors.append(interceptor)
    }

    deinit {
        taskObserver = nil
        authChallenge = nil
        retryClosure = nil
        session.invalidateAndCancel()
        session = nil
    }
    
}

extension LeafURLSession {

    func observe(_ task: URLSessionTask, _ leafTask: LeafTask?) {
        taskObserver?.add(task, leafTask)
        if let delegate = delegate as? LeafURLSessionDelegate {
            delegate.add(task, leafTask)
        }
    }

    func urlRequest(_ leafRequest: LeafRequest) -> URLRequest {
        var builder = leafRequest.builder()
        requestInterceptors.forEach({ interceptor in
            builder = interceptor(builder)
        })
        return builder.build().urlRequest
    }

    func leafRequest(_ url: URL, cache: LeafRequest.LeafCachePolicy? = nil, timeout: TimeInterval? = nil) -> LeafRequest {
        let cache = cache ?? LeafRequest.LeafCachePolicy(rawValue: session.configuration.requestCachePolicy.rawValue) ?? .useProtocolCachePolicy
        let timeout = timeout ?? session.configuration.timeoutIntervalForRequest
        return LeafRequest(url, cache: cache, timeout: timeout)
    }

    func leafTask(_ urlSessionTask: URLSessionTask, _ request: LeafRequest? = nil) -> LeafTask {
        if let currentRequest = urlSessionTask.currentRequest {
            return LeafTask(urlSessionTask, request: currentRequest.leafRequest)
        } else if let originalRequest = urlSessionTask.originalRequest {
            return LeafTask(urlSessionTask, request: originalRequest.leafRequest)
        }
        return LeafTask(urlSessionTask, request: request)
    }

    func leafResponse(_ response: URLResponse?, _ leafTask: LeafTask? = nil, _ responseObject: Any? = nil) -> LeafResponse? {
        var leafResponse: LeafResponse?
        if let httpResponse = response as? HTTPURLResponse {
            leafResponse = LeafResponse(httpResponse, leafTask, responseObject)
        } else if let response = response {
            leafResponse = LeafResponse(response, leafTask, responseObject)
        }
        guard let response = leafResponse else {
            return nil
        }
        var builder = response.builder()
        responseInterceptors.forEach({ interceptor in
            builder = interceptor(builder)
        })
        return builder.build()
    }

    func leafError(_ error: Error?, _ responseObject: Any? = nil, _ response: URLResponse? = nil) -> LeafError? {
        if let error = error {
            return LeafError.leaf(code: error._code, message: error.localizedDescription, headers: (response as? HTTPURLResponse)?.allHeaderFields, object: responseObject, underlying: error)
        }
        return nil
    }

    func process(_ leafTask: LeafTask?, _ leafResponse: LeafResponse?, _ leafError: LeafError?) {
        leafTask?.response = leafResponse
        leafTask?.error = leafError
        
        if let request = leafTask?.request, let retryCount = leafTask?.retryCount,
            (leafTask?.retryClosure?(leafResponse, leafError, retryCount) == true || retryClosure?(leafResponse, leafError, retryCount) == true) {
            
            let retryTask = self.dataTask(request)
            leafTask?.leafTask = retryTask.leafTask
            leafTask?.state = .suspended
            leafTask?.retryCount += 1
            retryTask.request = nil
            retryTask.progressClosure = { progress in
                leafTask?.progress = progress
                leafTask?.progressClosure?(progress)
            }
            retryTask.successClosure = { response in
                leafTask?.metrics = retryTask.metrics
                self.process(leafTask, response, nil)
            }
            retryTask.failureClosure = { error in
                leafTask?.metrics = retryTask.metrics
                self.process(leafTask, nil, error)
            }
            leafTask?.resume()
        } else {
            leafTask?.dispatchSemaphore?.signal()
            if let lr = leafResponse {
                leafTask?.successClosure?(lr)
            } else {
                leafTask?.failureClosure?(leafError ?? LeafError.unknown)
            }
        }
    }

}
