//
//  Tree.swift
//  Leaf
//
//  Created by 李二狗 on 2018/5/24.
//

import Foundation

public struct Tree {
    public var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    @discardableResult
    public func request(_ path: String,
                        method: LeafRequest.LeafMethod,
                        parameters: [String: Any]?,
                        headers: [String: String]? = nil,
                        cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                        body: LeafBodyType? = nil,
                        session: LeafURLSession = LeafURLSession.init(),
                        success: LeafTask.SuccessClosure?,
                        failure: LeafTask.FailureClosure?) -> Tree {
        do {
            try Leaf.init(self.baseURL + path, parameters: parameters, headers: headers, cachePolicy: cachePolicy, body: body, session: session)?.async(method, success: success, failure: failure)
        } catch {
            if let e = error as? LeafError {
                failure?(e)
            } else {
                failure?(LeafError.leafError(from: error))
            }
        }
        return self
    }
}
