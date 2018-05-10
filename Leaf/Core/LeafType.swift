//
//  Leaf.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public let kLeafSymbol = "🍃"

public typealias RequestInterceptor = (LeafRequest.Builder) -> LeafRequest.Builder

public typealias ResponseInterceptor = (LeafResponse.Builder) -> LeafResponse.Builder

public protocol LeafType: class {

    static var shared: LeafType { get }

    var requestInterceptors: [RequestInterceptor] { get set }

    var responseInterceptors: [ResponseInterceptor] { get set }

    var retryClosure: LeafTask.RetryClosure? { get set }

    func addRequestInterceptor(_ interceptor: @escaping RequestInterceptor)

    func addResponseInterceptor(_ interceptor: @escaping ResponseInterceptor)

    func dataTask(_ request: LeafRequest) -> LeafTask

    func downloadTask(_ resumeData: Data) -> LeafTask

    func downloadTask(_ request: LeafRequest) -> LeafTask

    func uploadTask(_ streamedRequest: LeafRequest) -> LeafTask

    func uploadTask(_ request: LeafRequest, data: Data) -> LeafTask

    func uploadTask(_ request: LeafRequest, fileURL: URL) -> LeafTask

    #if !os(watchOS)
    @available(iOS 9.0, macOS 10.11, *)
    func streamTask(_ service: NetService) -> LeafTask

    @available(iOS 9.0, macOS 10.11, *)
    func streamTask(_ domain: String, type: String, name: String, port: Int32?) -> LeafTask

    @available(iOS 9.0, macOS 10.11, *)
    func streamTask(_ hostName: String, port: Int) -> LeafTask
    #endif
}
