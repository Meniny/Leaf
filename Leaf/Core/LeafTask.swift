//
//  LeafTask.swift
//  Leaf
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

public typealias LeafTaskIdentifier = Int

public protocol LeafTaskProtocol: class {

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var progress: Progress { get }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    var earliestBeginDate: Date? { get set }

    func cancel()

    func suspend()

    func resume()

}

open class LeafTask {

    public enum LeafState : Int {
        case running, suspended, canceling, completed, waitingForConnectivity
    }

    open let identifier: LeafTaskIdentifier

    open var request: LeafRequest?

    open internal(set) var response: LeafResponse? {
        didSet {
            state = .completed
        }
    }

    open let taskDescription: String?

    open internal(set) var state: LeafState

    open internal(set) var error: LeafError? {
        didSet {
            state = .completed
        }
    }

    open internal(set) var priority: Float?

    open internal(set) var progress: Progress

    open internal(set) var metrics: LeafTaskMetrics?

    var leafTask: LeafTaskProtocol?

    open internal(set) var retryCount: UInt = 0

    fileprivate(set) var dispatchSemaphore: DispatchSemaphore?

    public typealias SuccessClosure = (LeafResponse) -> Swift.Void
    public typealias FailureClosure = (LeafError) -> Swift.Void
    public typealias RetryClosure = (LeafResponse?, LeafError?, UInt) -> Bool
    public typealias ProgressClosure = (Progress) -> Swift.Void
    
    var successClosure: LeafTask.SuccessClosure?
    var failureClosure: LeafTask.FailureClosure?

    fileprivate(set) var retryClosure: LeafTask.RetryClosure?

    var progressClosure: LeafTask.ProgressClosure?

    public init(_ identifier: LeafTaskIdentifier? = nil, request: LeafRequest? = nil , response: LeafResponse? = nil, taskDescription: String? = nil, state: LeafState = .suspended, error: LeafError? = nil, priority: Float? = nil, progress: Progress? = nil, metrics: LeafTaskMetrics? = nil, task: LeafTaskProtocol? = nil) {
        self.request = request
        self.identifier = identifier ?? LeafTaskIdentifier(arc4random())
        self.response = response
        self.taskDescription = taskDescription ?? request?.description
        self.state = state
        self.error = error
        self.priority = priority
        if let p = progress {
            self.progress = p
        } else if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *), let p = task?.progress {
            self.progress = p
        } else {
            self.progress = Progress.init(totalUnitCount: Int64(request?.contentLength ?? 0))
        }
        self.leafTask = task
    }

    deinit {
        successClosure = nil
        failureClosure = nil
        progressClosure = nil
        retryClosure = nil
    }

}

extension LeafTask {

    @discardableResult open func async(success: LeafTask.SuccessClosure?, failure: LeafTask.FailureClosure?) -> Self {
        guard state == .suspended else {
            return self
        }
        successClosure = success
        failureClosure = failure
        resume()
        return self
    }

    open func sync() throws -> LeafResponse {
        guard state == .suspended else {
            if let response = response {
                return response
            } else if let error = error {
                throw error
            } else {
                throw LeafError.leaf(code: error?.code, message: error?.message ?? "", headers: response?.headers, object: response?.responseObject, underlying: error?.underlying)
            }
        }
        dispatchSemaphore = DispatchSemaphore(value: 0)
        resume()
        let dispatchTimeoutResult = dispatchSemaphore?.wait(timeout: DispatchTime.distantFuture)
        if dispatchTimeoutResult == .timedOut {
            let urlError = URLError(.timedOut)
            error = LeafError.leaf(code: urlError._code, message: urlError.localizedDescription, headers: response?.headers, object: response?.responseObject, underlying: urlError)
        }
        if let error = error {
            throw error
        }
        return response!
    }

    open func cached() throws -> LeafResponse {
        if let response = response {
            return response
        }
        guard let urlRequest = request?.urlRequest else {
            guard let taskError = error else {
                let error = URLError(.resourceUnavailable)
                throw LeafError.leaf(code: error._code, message: "Request not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
            }
            throw taskError
        }
        if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
            return LeafResponse(cachedResponse, self)
        }
        guard let taskError = error else {
            let error = URLError(.resourceUnavailable)
            throw LeafError.leaf(code: error._code, message: "Cached response not found.", headers: response?.headers, object: response?.responseObject, underlying: error)
        }
        throw taskError
    }

    @discardableResult open func retry(_ retry: LeafTask.RetryClosure?) -> Self {
        retryClosure = retry
        return self
    }

}

extension LeafTask {

    @discardableResult open func progress(_ progressClosure: LeafTask.ProgressClosure?) -> Self {
        self.progressClosure = progressClosure
        return self
    }

}

extension LeafTask: LeafTaskProtocol {

    open var earliestBeginDate: Date? {
        get {
            guard #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) else {
                return nil
            }
            return leafTask?.earliestBeginDate
        }
        set {
            if #available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *) {
                leafTask?.earliestBeginDate = newValue
            }
        }
    }

    open func cancel() {
        state = .canceling
        leafTask?.cancel()
    }

    open func suspend() {
        state = .suspended
        leafTask?.suspend()
    }

    open func resume() {
        state = .running
        leafTask?.resume()
    }

}

extension LeafTask: Hashable {

    open var hashValue: Int {
        return identifier.hashValue
    }
    
}

extension LeafTask: Equatable {

    open static func ==(lhs: LeafTask, rhs: LeafTask) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension LeafTask: CustomStringConvertible {

    open var description: String {
        var description = String(describing: LeafTask.self) + " " + identifier.description + " (" + String(describing: state) + ")"
        if let taskDescription = taskDescription {
            description = description + " " + taskDescription
        }
        return description
    }

}

extension LeafTask: CustomDebugStringConvertible {

    open var debugDescription: String {
        return description
    }
    
}
