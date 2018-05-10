//
//  LeafTaskMetrics+URLSessionTaskMetrics.swift
//  Leaf
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

@available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *)
extension LeafTaskMetrics {

    public init(_ urlSessionTaskMetrics: URLSessionTaskMetrics, request: LeafRequest? = nil, response: LeafResponse? = nil) {
        var transactionMetrics = [LeafTransactionMetrics]()
        #if !os(watchOS)
        transactionMetrics = urlSessionTaskMetrics.transactionMetrics.flatMap {
            LeafTransactionMetrics(request: request, response: response, fetchStartDate: $0.fetchStartDate, domainLookupStartDate: $0.domainLookupStartDate, domainLookupEndDate: $0.domainLookupEndDate, connectStartDate: $0.connectStartDate, secureConnectionStartDate: $0.secureConnectionStartDate, secureConnectionEndDate: $0.secureConnectionEndDate, connectEndDate: $0.connectEndDate, requestStartDate: $0.requestStartDate, requestEndDate: $0.requestEndDate, responseStartDate: $0.responseStartDate, responseEndDate: $0.responseEndDate, networkProtocolName: $0.networkProtocolName, isProxyConnection: $0.isProxyConnection, isReusedConnection: $0.isReusedConnection, resourceFetchType: LeafTransactionMetrics.LeafResourceFetchType(rawValue: $0.resourceFetchType.rawValue) ?? .unknown)
        }
        #endif
        self.init(transactionMetrics: transactionMetrics, taskInterval: urlSessionTaskMetrics.taskInterval.duration, redirectCount: urlSessionTaskMetrics.redirectCount)
    }
    
}
