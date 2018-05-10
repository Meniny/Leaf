//
//  LeafResponse.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public struct LeafResponse {

    public let url: URL?

    public let mimeType: String?

    public let contentLength: Int64?

    public let textEncoding: String?

    public let filename: String?

    public let statusCode: Int?

    public let headers: [AnyHashable : Any]?

    public let localizedDescription: String?

    public let userInfo: [AnyHashable : Any]?

    public weak var leafTask: LeafTask?

    public let responseObject: Any?
    
    public let response: URLResponse?

}

extension LeafResponse {

    public init(_ url: URL? = nil, mimeType: String? = nil, contentLength: Int64 = -1, textEncoding: String? = nil, filename: String? = nil, statusCode: Int? = nil, headers: [AnyHashable : Any]? = nil, localizedDescription: String? = nil, userInfo: [AnyHashable : Any]? = nil, leafTask: LeafTask?, responseObject: Any? = nil, response: URLResponse?) {
        self.url = url
        self.mimeType = mimeType
        self.contentLength = contentLength != -1 ? contentLength : nil
        self.textEncoding = textEncoding
        self.filename = filename
        self.statusCode = statusCode
        self.headers = headers
        self.localizedDescription = localizedDescription
        self.userInfo = userInfo
        self.leafTask = leafTask
        self.responseObject = responseObject
        self.response = response
    }

}

extension LeafResponse {
    
    public func data() throws -> Data {
        do {
            return try LeafTransformer.object(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    public func object<T>() throws -> T {
        do {
            return try LeafTransformer.object(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    public func decode<D: Decodable>() throws -> D {
        do {
            return try LeafTransformer.decode(object: responseObject)
        } catch {
            throw handle(error)
        }
    }

    private func handle(_ error: Error) -> Error {
        guard let e = error as? LeafError else {
            return error
        }
        switch e {
        case .parse(let transformCode, let message, let object, let underlying):
            return LeafError.parse(code: transformCode ?? statusCode, message: message, object: object ?? responseObject, underlying: underlying)
        default:
            return e
        }
    }

}

extension LeafResponse: Equatable {

    public static func ==(lhs: LeafResponse, rhs: LeafResponse) -> Bool {
        guard lhs.url != nil && rhs.url != nil else {
            return false
        }
        return lhs.url == rhs.url
    }

}

extension LeafResponse: CustomStringConvertible {

    public var description: String {
        var description = ""
        if let statusCode = statusCode?.description {
            description = description + statusCode
        }
        if let url = url?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + url
        }
        if let localizedDescription = localizedDescription?.description {
            if description.count > 0 {
                description = description + " "
            }
            description = description + "(\(localizedDescription))"
        }
        return description
    }

}

extension LeafResponse: CustomDebugStringConvertible {

    public var debugDescription: String {
        return description
    }
    
}
