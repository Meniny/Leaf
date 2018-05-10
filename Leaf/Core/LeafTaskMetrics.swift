//
//  LeafTaskMetrics.swift
//  Leaf
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

public struct LeafTaskMetrics {

    public struct LeafTransactionMetrics {

        public enum LeafResourceFetchType : Int {
            case unknown, networkLoad, serverPush, localCache
        }

        public let request: LeafRequest?

        public let response: LeafResponse?

        public let fetchStartDate: Date?

        public let domainLookupStartDate: Date?

        public let domainLookupEndDate: Date?

        public let connectStartDate: Date?

        public let secureConnectionStartDate: Date?

        public let secureConnectionEndDate: Date?

        public let connectEndDate: Date?

        public let requestStartDate: Date?

        public let requestEndDate: Date?

        public let responseStartDate: Date?

        public let responseEndDate: Date?

        public let networkProtocolName: String?

        public let isProxyConnection: Bool

        public let isReusedConnection: Bool

        public let resourceFetchType: LeafResourceFetchType

    }

    public let transactionMetrics: [LeafTransactionMetrics]

    public let taskInterval: TimeInterval

    public let redirectCount: Int
    
}
