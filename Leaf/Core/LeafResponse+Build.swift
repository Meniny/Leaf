//
//  LeafResponse+Build.swift
//  Leaf
//
//  Created by Elias Abel on 28/3/17.
//
//

import Foundation

extension LeafResponse {

    public class Builder {

        public private(set) var url: URL?

        public private(set) var mimeType: String?

        public private(set) var contentLength: Int64

        public private(set) var textEncoding: String?

        public private(set) var filename: String?

        public private(set) var statusCode: Int?

        public private(set) var headers: [AnyHashable : Any]?

        public private(set) var localizedDescription: String?

        public private(set) var userInfo: [AnyHashable : Any]?

        public private(set) weak var leafTask: LeafTask?
        
        public private(set) var responseObject: Any?
        
        public private(set) var response: URLResponse?

        public init(_ leafResponse: LeafResponse? = nil) {
            url = leafResponse?.url
            mimeType = leafResponse?.mimeType
            contentLength = leafResponse?.contentLength ?? -1
            textEncoding = leafResponse?.textEncoding
            filename = leafResponse?.filename
            statusCode = leafResponse?.statusCode
            headers = leafResponse?.headers
            localizedDescription = leafResponse?.localizedDescription
            userInfo = leafResponse?.userInfo
            leafTask = leafResponse?.leafTask
            responseObject = leafResponse?.responseObject
            response = leafResponse?.response
        }

        @discardableResult open func setURL(_ url: URL?) -> Self {
            self.url = url
            return self
        }

        @discardableResult open func setMimeType(_ mimeType: String?) -> Self {
            self.mimeType = mimeType
            return self
        }

        @discardableResult open func setContentLength(_ contentLength: Int64) -> Self {
            self.contentLength = contentLength
            return self
        }

        @discardableResult open func setTextEncoding(_ textEncoding: String?) -> Self {
            self.textEncoding = textEncoding
            return self
        }

        @discardableResult open func setFilename(_ filename: String?) -> Self {
            self.filename = filename
            return self
        }

        @discardableResult open func setStatusCode(_ statusCode: Int?) -> Self {
            self.statusCode = statusCode
            return self
        }

        @discardableResult open func setHeaders(_ headers: [AnyHashable : Any]?) -> Self {
            self.headers = headers
            return self
        }

        @discardableResult open func setDescription(_ localizedDescription: String?) -> Self {
            self.localizedDescription = localizedDescription
            return self
        }

        @discardableResult open func setUserInfo(_ userInfo: [AnyHashable : Any]?) -> Self {
            self.userInfo = userInfo
            return self
        }

        @discardableResult open func setNetTask(_ leafTask: LeafTask?) -> Self {
            self.leafTask = leafTask
            return self
        }

        @discardableResult open func setObject(_ responseObject: Any?) -> Self {
            self.responseObject = responseObject
            return self
        }

        public func build() -> LeafResponse {
            return LeafResponse(self)
        }

    }

    public func builder() -> Builder {
        return LeafResponse.builder(self)
    }

    public static func builder(_ leafResponse: LeafResponse? = nil) -> Builder {
        return Builder(leafResponse)
    }

    public init(_ builder: Builder) {
        self.init(builder.url, mimeType: builder.mimeType, contentLength: builder.contentLength, textEncoding: builder.textEncoding, filename: builder.filename, statusCode: builder.statusCode, headers: builder.headers, localizedDescription: builder.localizedDescription, userInfo: builder.userInfo, leafTask: builder.leafTask, responseObject: builder.responseObject, response: builder.response)
    }

}
