//
//  Leaf.swift
//  Leaf
//
//  Created by 李二狗 on 2018/5/10.
//

import Foundation

open class Leaf: LeafType {
    open static var shared: LeafType {
        return self.default
    }
    
    private static let `default` = Leaf.init()
    
    open var session: LeafURLSession = LeafURLSession.init()
    open var request: LeafRequest?
    
    public init() {}
    
    public convenience init(request: LeafRequest) {
        self.init()
        self.request = request
    }
    
    public convenience init?(url: String) {
        guard let r = LeafRequest.init(url) else {
            return nil
        }
        self.init(request: r)
    }
    
    public convenience init(url: URL) {
        self.init(request: LeafRequest.init(url))
    }
    
    open var requestInterceptors: [RequestInterceptor] {
        get {
            return self.session.requestInterceptors
        }
        set {
            self.session.requestInterceptors = newValue
        }
    }
    
    open var responseInterceptors: [ResponseInterceptor] {
        get {
            return self.session.responseInterceptors
        }
        set {
            self.session.responseInterceptors = newValue
        }
    }
    
    open var retryClosure: LeafTask.RetryClosure? {
        get {
            return self.session.retryClosure
        }
        set {
            self.session.retryClosure = newValue
        }
    }
    
    open func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor) {
        self.session.addRequestInterceptor(interceptor)
    }
    
    open func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor) {
        self.session.addResponseInterceptor(interceptor)
    }
    
    open func dataTask(_ request: LeafRequest) -> LeafTask {
        return self.session.dataTask(request)
    }
    
    open func downloadTask(_ resumeData: Data) -> LeafTask {
        return self.session.downloadTask(resumeData)
    }
    
    open func downloadTask(_ request: LeafRequest) -> LeafTask {
        return self.session.downloadTask(request)
    }
    
    open func uploadTask(_ streamedRequest: LeafRequest) -> LeafTask {
        return self.session.uploadTask(streamedRequest)
    }
    
    open func uploadTask(_ request: LeafRequest, data: Data) -> LeafTask {
        return self.session.uploadTask(request, data: data)
    }
    
    open func uploadTask(_ request: LeafRequest, fileURL: URL) -> LeafTask {
        return self.session.uploadTask(request, fileURL: fileURL)
    }
    
    #if !os(watchOS)
    @available(iOS 9.0, macOS 10.11, *)
    open func streamTask(_ service: NetService) -> LeafTask {
        return self.session.streamTask(service)
    }
    
    @available(iOS 9.0, macOS 10.11, *)
    open func streamTask(_ domain: String, type: String, name: String, port: Int32?) -> LeafTask {
        return self.session.streamTask(domain, type: type, name: name, port: port)
    }
    
    @available(iOS 9.0, macOS 10.11, *)
    open func streamTask(_ hostName: String, port: Int) -> LeafTask {
        return self.session.streamTask(hostName, port: port)
    }
    #endif
}

public extension Leaf {
    open static var requestInterceptors: [RequestInterceptor] {
        get {
            return self.default.requestInterceptors
        }
        set {
            self.default.requestInterceptors = newValue
        }
    }
    
    open static var responseInterceptors: [ResponseInterceptor] {
        get {
            return self.default.responseInterceptors
        }
        set {
            self.default.responseInterceptors = newValue
        }
    }
    
    open static var retryClosure: LeafTask.RetryClosure? {
        get {
            return self.default.retryClosure
        }
        set {
            self.default.retryClosure = newValue
        }
    }
    
    open class func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor) {
        self.default.addRequestInterceptor(interceptor)
    }
    
    open class func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor) {
        self.default.addResponseInterceptor(interceptor)
    }
    
    open class func dataTask(_ request: LeafRequest) -> LeafTask {
        return self.default.dataTask(request)
    }
    
    open class func downloadTask(_ resumeData: Data) -> LeafTask {
        return self.default.downloadTask(resumeData)
    }
    
    open class func downloadTask(_ request: LeafRequest) -> LeafTask {
        return self.default.downloadTask(request)
    }
    
    open class func uploadTask(_ streamedRequest: LeafRequest) -> LeafTask {
        return self.default.uploadTask(streamedRequest)
    }
    
    open class func uploadTask(_ request: LeafRequest, data: Data) -> LeafTask {
        return self.default.uploadTask(request, data: data)
    }
    
    open class func uploadTask(_ request: LeafRequest, fileURL: URL) -> LeafTask {
        return self.default.uploadTask(request, fileURL: fileURL)
    }
    
    #if !os(watchOS)
    @available(iOS 9.0, macOS 10.11, *)
    open class func streamTask(_ service: NetService) -> LeafTask {
        return self.default.streamTask(service)
    }
    
    @available(iOS 9.0, macOS 10.11, *)
    open class func streamTask(_ domain: String, type: String, name: String, port: Int32?) -> LeafTask {
        return self.default.streamTask(domain, type: type, name: name, port: port)
    }
    
    @available(iOS 9.0, macOS 10.11, *)
    open class func streamTask(_ hostName: String, port: Int) -> LeafTask {
        return self.default.streamTask(hostName, port: port)
    }
    #endif
}

public extension Leaf {
//    public class func request(_ url: URL,
//                              method: LeafRequest.LeafMethod,
//                              parameters: [String: Any]?,
//                              headers: [String: String]? = nil,
//                              allowsCellularAccess: Bool = true,
//                              cache: LeafRequest.LeafCachePolicy = .useProtocolCachePolicy,
//                              timeout: TimeInterval = 60) -> Leaf {
//        let request = LeafRequest.init(url: url, cache: cache, timeout: timeout, mainDocumentURL: nil, serviceType: .default, contentType: nil, contentLength: nil, accept: nil, acceptEncoding: nil, cacheControl: nil, allowsCellularAccess: allowsCellularAccess, httpMethod: method, headers: headers, body: nil, bodyStream: nil, handleCookies: true, usePipelining: true, authorization: .none)
//        let builder = request.builder()
//        builder.setMethod(method)
//            .setURLParameters(parameters)
//            .setTimeout(timeout)
//            .setHeaders(headers)
//            .setAccept(accept)
//            .setCache(cachePolicy)
//            .setContentType(contentType)
//            .setServiceType(serviceType)
//            .setCacheControls(cacheControls)
//    }
}
