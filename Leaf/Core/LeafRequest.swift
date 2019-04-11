//
//  LeafRequest.swift
//  Leaf
//
//  Created by Elias Abel on 23/3/17.
//
//

import Foundation

public struct LeafRequest {

    public typealias LeafContentLength = UInt64

    public enum LeafCachePolicy: UInt, Equatable {
        case useProtocolCachePolicy = 0, reloadIgnoringLocalCacheData = 1, returnCacheDataElseLoad = 2, returnCacheDataDontLoad = 3
    }

    public enum LeafServiceType: UInt, Equatable {
        case `default`, voip, video, background, voice, callSignaling = 11
    }

    public enum LeafMethod: String, Equatable {
        case GET, POST, PUT, DELETE, PATCH, UPDATE, HEAD, TRACE, OPTIONS, CONNECT, SEARCH, COPY, MERGE, LABEL, LOCK, UNLOCK, MOVE, MKCOL, PROPFIND, PROPPATCH
    }

    public enum LeafContentEncoding: String, Equatable {
        case gzip, compress, deflate, identity, br
    }

    public let url: URL

    public let cache: LeafCachePolicy

    public let timeout: TimeInterval

    public let mainDocumentURL: URL?

    public let serviceType: LeafServiceType

    public let contentType: LeafContentType?

    public let contentLength: LeafContentLength?

    public let accept: LeafContentType?

    public let acceptEncoding: [LeafContentEncoding]?

    public let cacheControl: [LeafCacheControl]?

    public let allowsCellularAccess: Bool

    public let httpMethod: LeafMethod

    public let headers: [String : String]?

    public let body: Data?

    public let bodyStream: InputStream?

    public let handleCookies: Bool

    public let usePipelining: Bool

    public let authorization: LeafAuthorization

}

extension LeafRequest {

    public init(_ url: URL, cache: LeafCachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 60, mainDocumentURL: URL? = nil, serviceType: LeafServiceType = .default, contentType: LeafContentType? = nil, contentLength: LeafContentLength? = nil, accept: LeafContentType? = nil, acceptEncoding: [LeafContentEncoding]? = nil, cacheControl: [LeafCacheControl]? = nil, allowsCellularAccess: Bool = true, method: LeafMethod = .GET, headers: [String : String]? = nil, body: Data? = nil, bodyStream: InputStream? = nil, handleCookies: Bool = true, usePipelining: Bool = true, authorization: LeafAuthorization = .none) {
        self.url = url
        self.cache = cache
        self.timeout = timeout
        self.mainDocumentURL = mainDocumentURL
        self.serviceType = serviceType
        self.contentType = contentType
        self.contentLength = contentLength
        self.accept = accept
        self.acceptEncoding = acceptEncoding
        self.cacheControl = cacheControl
        self.allowsCellularAccess = allowsCellularAccess
        self.httpMethod = method
        self.headers = headers
        self.body = body
        self.bodyStream = bodyStream
        self.handleCookies = handleCookies
        self.usePipelining = usePipelining
        self.authorization = authorization
    }
    
}

extension LeafRequest {

    public init?(_ urlString: String, cache: LeafCachePolicy = .useProtocolCachePolicy, timeout: TimeInterval = 60, mainDocumentURL: URL? = nil, serviceType: LeafServiceType = .default, contentType: LeafContentType? = nil, contentLength: LeafContentLength? = nil, accept: LeafContentType? = nil, acceptEncoding: [LeafContentEncoding]? = nil, cacheControl: [LeafCacheControl]? = nil, allowsCellularAccess: Bool = true, method: LeafMethod = .GET, headers: [String : String]? = nil, body: Data? = nil, bodyStream: InputStream? = nil, handleCookies: Bool = true, usePipelining: Bool = true, authorization: LeafAuthorization = .none) {
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.init(url, cache: cache, timeout: timeout, mainDocumentURL: mainDocumentURL, serviceType: serviceType, contentType: contentType, contentLength: contentLength, accept: accept, acceptEncoding: acceptEncoding, cacheControl: cacheControl, allowsCellularAccess: allowsCellularAccess, method: method, headers: headers, body: body, bodyStream: bodyStream, handleCookies: handleCookies, usePipelining: usePipelining, authorization: authorization)
    }

}

extension LeafRequest: CustomStringConvertible {

    public var description: String {
        return httpMethod.rawValue + " " + url.absoluteString
    }

}

extension LeafRequest: CustomDebugStringConvertible {

    public var debugDescription: String {
        var components = ["$ curl -i"]

        if httpMethod != .GET {
            components.append("-X \(httpMethod.rawValue)")
        }

        if let headers = headers {
            for (field, value) in headers where field != "Content-Type" && field != "Accept" && field != "Accept-Encoding" && field != "Cache-Control" && field != "Content-Length" {
                components.append("-H \"\(field): \(value)\"")
            }
        }

        if let contentType = contentType {
            components.append("-H \"Content-Type: \(contentType.rawValue)\"")
        }

        if let contentLength = contentLength {
            components.append("-H \"Content-Length: \(contentLength)\"")
        }

        if let accept = accept {
            components.append("-H \"Accept: \(accept.rawValue)\"")
        }

        if let acceptEncoding = acceptEncoding {
            components.append("-H \"Accept-Encoding: \(acceptEncoding.compactMap({$0.rawValue}).joined(separator: ", "))\"")
        }

        if let cacheControl = cacheControl {
            components.append("-H \"Cache-Control: \(cacheControl.compactMap({$0.rawValue}).joined(separator: ", "))\"")
        }

        if authorization != .none {
            components.append("-H \"Authorization: \(authorization.rawValue)\"")
        }

        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            var escapedBody = bodyString.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        components.append("\"\(url.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }

}

extension LeafRequest: Hashable {

    public var hashValue: Int {
        return url.hashValue + httpMethod.hashValue
    }

}

extension LeafRequest: Equatable {

    public static func ==(lhs: LeafRequest, rhs: LeafRequest) -> Bool {
        return lhs.url == rhs.url && lhs.httpMethod == rhs.httpMethod
    }

}
