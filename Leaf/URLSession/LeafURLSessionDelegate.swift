//
//  LeafURLSessionDelegate.swift
//  Leaf
//
//  Created by Elias Abel on 17/3/17.
//
//

import Foundation

class LeafURLSessionDelegate: NSObject {

    fileprivate weak final var leafURLSession: LeafURLSession?

    final var tasks = [URLSessionTask: LeafTask]()

    init(_ urlSession: LeafURLSession) {
        leafURLSession = urlSession
        super.init()
    }

    func add(_ task: URLSessionTask, _ leafTask: LeafTask?) {
        tasks[task] = leafTask
    }

    deinit {
        tasks.removeAll()
        leafURLSession = nil
    }

}

extension LeafURLSessionDelegate: URLSessionDelegate {}

extension LeafURLSessionDelegate: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        handle(challenge, tasks[task], completion: completionHandler)
    }

    @available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting taskMetrics: URLSessionTaskMetrics) {
        if let leafTask = tasks[task] {
            leafTask.metrics = LeafTaskMetrics(taskMetrics, request: leafTask.request, response: leafTask.response)
        }
        tasks[task] = nil
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        completionHandler(.continueLoading, nil)
    }

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        if let leafTask = tasks[task] {
            leafTask.state = .waitingForConnectivity
        }
    }

}

extension LeafURLSessionDelegate: URLSessionDataDelegate {}


extension LeafURLSessionDelegate: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
}

@available(iOS 9.0, *)
extension LeafURLSessionDelegate: URLSessionStreamDelegate {}

extension LeafURLSessionDelegate {

    fileprivate func handle(_ challenge: URLAuthenticationChallenge, _ leafTask: LeafTask? = nil, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard let authChallenge = leafURLSession?.authChallenge else {
            guard challenge.previousFailureCount == 0 else {
                challenge.sender?.cancel(challenge)
                if let realm = challenge.protectionSpace.realm {
                    print(realm)
                    print(challenge.protectionSpace.authenticationMethod)
                }
                completion(.cancelAuthenticationChallenge, nil)
                return
            }

            var credential: URLCredential? = challenge.proposedCredential

            if credential?.hasPassword != true, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest, let request = leafTask?.request {
                switch request.authorization {
                case .basic(let user, let password):
                    credential = URLCredential(user: user, password: password, persistence: .forSession)
                default:
                    break
                }
            }

            if credential == nil, challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let serverTrust = challenge.protectionSpace.serverTrust {
                let host = challenge.protectionSpace.host
                if let policy = leafURLSession?.serverTrust[host] {
                    if policy.evaluate(serverTrust, host: host) {
                        credential = URLCredential(trust: serverTrust)
                    } else {
                        credential = nil
                    }
                } else {
                    credential = URLCredential(trust: serverTrust)
                }
            }

            completion(credential != nil ? .useCredential : .cancelAuthenticationChallenge, credential)
            return
        }
        authChallenge(challenge, completion)
    }

}
