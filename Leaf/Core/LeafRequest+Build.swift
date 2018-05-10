//
//  LeafRequest+Build.swift
//  Leaf
//
//  Created by Elias Abel on 25/3/17.
//
//

import Foundation

extension LeafRequest {

    public class Builder {

        public private(set) var url: URL

        public private(set) var cache: LeafRequest.LeafCachePolicy?

        public private(set) var timeout: TimeInterval?

        public private(set) var mainDocumentURL: URL?

        public private(set) var serviceType: LeafRequest.LeafServiceType?

        public private(set) var contentType: LeafContentType?

        public private(set) var contentLength: LeafContentLength?

        public private(set) var accept: LeafContentType?

        public private(set) var acceptEncoding: [LeafContentEncoding]?

        public private(set) var cacheControl: [LeafCacheControl]?

        public private(set) var allowsCellularAccess: Bool?

        public private(set) var method: LeafRequest.LeafMethod?

        public private(set) var headers: [String : String]?

        public private(set) var body: Data?

        public private(set) var bodyStream: InputStream?

        public private(set) var handleCookies: Bool?

        public private(set) var usePipelining: Bool?

        public private(set) var authorization: LeafAuthorization?

        public init(_ leafRequest: LeafRequest) {
            url = leafRequest.url
            cache = leafRequest.cache
            timeout = leafRequest.timeout
            mainDocumentURL = leafRequest.mainDocumentURL
            serviceType = leafRequest.serviceType
            contentType = leafRequest.contentType
            contentLength = leafRequest.contentLength
            accept = leafRequest.accept
            acceptEncoding = leafRequest.acceptEncoding
            cacheControl = leafRequest.cacheControl
            allowsCellularAccess = leafRequest.allowsCellularAccess
            method = leafRequest.httpMethod != .GET ? leafRequest.httpMethod : nil
            headers = leafRequest.headers
            body = leafRequest.body
            bodyStream = leafRequest.bodyStream
            handleCookies = leafRequest.handleCookies
            usePipelining = leafRequest.usePipelining
            authorization = leafRequest.authorization
        }

        public convenience init?(_ urlRequest: URLRequest) {
            guard let leafRequest = urlRequest.leafRequest else {
                return nil
            }
            self.init(leafRequest)
        }

        public init(_ url: URL) {
            self.url = url
        }

        public convenience init?(_ urlString: String) {
            guard let url = URL(string: urlString) else {
                return nil
            }
            self.init(url)
        }

        @discardableResult open func setCache(_ cache: LeafRequest.LeafCachePolicy?) -> Self {
            self.cache = cache
            return self
        }

        @discardableResult open func setTimeout(_ timeout: TimeInterval?) -> Self {
            self.timeout = timeout
            return self
        }

        @discardableResult open func setMainDocumentURL(_ mainDocumentURL: URL?) -> Self {
            self.mainDocumentURL = mainDocumentURL
            return self
        }

        @discardableResult open func setServiceType(_ serviceType: LeafRequest.LeafServiceType?) -> Self {
            self.serviceType = serviceType
            return self
        }

        @discardableResult open func setContentType(_ contentType: LeafContentType?) -> Self {
            self.contentType = contentType
            return self
        }

        @discardableResult open func setContentLength(_ contentLength: LeafContentLength?) -> Self {
            self.contentLength = contentLength
            return self
        }

        @discardableResult open func setAccept(_ accept: LeafContentType?) -> Self {
            self.accept = accept
            return self
        }

        @discardableResult open func setAcceptEncodings(_ acceptEncodings: [LeafContentEncoding]?) -> Self {
            self.acceptEncoding = acceptEncodings
            return self
        }

        @discardableResult open func addAcceptEncoding(_ acceptEncoding: LeafContentEncoding?) -> Self {
            if self.acceptEncoding == nil {
                setAcceptEncodings([])
            }
            if let acceptEncoding = acceptEncoding, var acceptEncodings = self.acceptEncoding {
                if acceptEncodings.contains(acceptEncoding), let index = acceptEncodings.index(of: acceptEncoding) {
                    acceptEncodings.remove(at: index)
                }
                acceptEncodings.append(acceptEncoding)
                setAcceptEncodings(acceptEncodings)
            }
            return self
        }

        @discardableResult open func setCacheControls(_ cacheControls: [LeafCacheControl]?) -> Self {
            self.cacheControl = cacheControls
            return self
        }

        @discardableResult open func addCacheControl(_ cacheControl: LeafCacheControl?) -> Self {
            if self.cacheControl == nil {
                setCacheControls([])
            }
            if let cacheControl = cacheControl, var cacheControls = self.cacheControl {
                if cacheControls.contains(cacheControl), let index = cacheControls.index(of: cacheControl) {
                    cacheControls.remove(at: index)
                }
                cacheControls.append(cacheControl)
                setCacheControls(cacheControls)
            }
            return self
        }

        @discardableResult open func setAllowsCellularAccess(_ allowsCellularAccess: Bool?) -> Self {
            self.allowsCellularAccess = allowsCellularAccess
            return self
        }

        @discardableResult open func setMethod(_ method: LeafRequest.LeafMethod?) -> Self {
            self.method = method
            return self
        }

        @discardableResult open func setHeaders(_ headers: [String : String]?) -> Self {
            self.headers = headers
            return self
        }

        @discardableResult open func addHeader(_ key: String, value: String?) -> Self {
            if self.headers == nil {
                setHeaders([:])
            }
            self.headers?[key] = value
            return self
        }

        @discardableResult open func setBody(_ body: Data?) -> Self {
            if body != nil {
                setBodyStream(nil)
                if contentType == nil {
                    setContentType(.bin)
                }
                if method == nil {
                    setMethod(.POST)
                }
                if contentLength == nil, let length = body?.count {
                    setContentLength(LeafContentLength(length))
                }
            }
            self.body = body
            return self
        }

        @discardableResult open func setURLParameters(_ urlParameters: [String: Any]?, resolvingAgainstBaseURL: Bool = false, removeCurrentPercentEncodedQuery: Bool = false) -> Self {
            if var components = URLComponents.init(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                if removeCurrentPercentEncodedQuery {
                    components.percentEncodedQuery = nil
                }
                if let urlParameters = urlParameters {
                    if !urlParameters.isEmpty {
                        let queried = query(urlParameters)
                        components.percentEncodedQuery = queried
                    }
                }
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult open func addURLParameter(_ key: String, value: Any?, resolvingAgainstBaseURL: Bool = false) -> Self {
            guard let value = value else {
                return self
            }
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: resolvingAgainstBaseURL) {
                let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query([key: value])
                components.percentEncodedQuery = percentEncodedQuery
                if let url = components.url {
                    self.url = url
                }
            }
            return self
        }

        @discardableResult open func setFormParameters(_ formParameters: [String: Any]?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let formParameters = formParameters else {
                return self
            }
            body = query(formParameters).data(using: encoding, allowLossyConversion: allowLossyConversion)
            if contentType == nil {
                setContentType(.formURL)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setStringBody(_ stringBody: String?, encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Self {
            guard let stringBody = stringBody else {
                return self
            }
            body = stringBody.data(using: encoding, allowLossyConversion: allowLossyConversion)
            if contentType == nil {
                setContentType(.txt)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setJSONObject<T: Encodable>(_ jsonObject: T?) throws -> Self {
            guard let jsonObject = jsonObject else {
                return self
            }
            body = try JSONEncoder().encode(jsonObject)
            if contentType == nil {
                setContentType(.json)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setJSONBody(_ jsonBody: Any?, options: JSONSerialization.WritingOptions = .prettyPrinted) throws -> Self {
            guard let jsonBody = jsonBody else {
                return self
            }
            body = try JSONSerialization.data(withJSONObject: jsonBody, options: options)
            if contentType == nil {
                setContentType(.json)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setPlistObject<T: Encodable>(_ plistObject: T?) throws -> Self {
            guard let plistObject = plistObject else {
                return self
            }
            body = try PropertyListEncoder().encode(plistObject)
            if contentType == nil {
                setContentType(.plist)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setPlistBody(_ plistBody: Any?, format: PropertyListSerialization.PropertyListFormat = .xml, options: PropertyListSerialization.WriteOptions = 0) throws -> Self {
            guard let plistBody = plistBody else {
                return self
            }
            body = try PropertyListSerialization.data(fromPropertyList: plistBody, format: format, options: options)
            if contentType == nil {
                setContentType(.plist)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil, let length = body?.count {
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setBodyStream(_ bodyStream: InputStream?) -> Self {
            if bodyStream != nil {
                setBody(nil)
                if contentType == nil {
                    setContentType(.bin)
                }
                if method == nil {
                    setMethod(.POST)
                }
            }
            self.bodyStream = bodyStream
            return self
        }

        @discardableResult open func setMultipartFormData(_ multipartFormData: LeafMultipartFormData?) throws -> Self {
            guard let multipartFormData = multipartFormData else {
                return self
            }
            body = try multipartFormData.encode()
            setContentType(.custom(multipartFormData.contentType))
            setContentLength(multipartFormData.contentLength)
            if method == nil {
                setMethod(.POST)
            }
            return self
        }
        
        @discardableResult open func setCustomBody(_ customBody: Data?, contentType ct: LeafContentType) -> Self {
            guard let customBody = customBody else {
                return self
            }
            body = customBody
            if contentType == nil {
                setContentType(ct)
            }
            if method == nil {
                setMethod(.POST)
            }
            if contentLength == nil {
                let length = customBody.count
                setContentLength(LeafContentLength(length))
            }
            return self
        }

        @discardableResult open func setHandleCookies(_ handleCookies: Bool?) -> Self {
            self.handleCookies = handleCookies
            return self
        }

        @discardableResult open func setUsePipelining(_ usePipelining: Bool?) -> Self {
            self.usePipelining = usePipelining
            return self
        }

        @discardableResult open func setBasicAuthorization(user: String, password: String) -> Self {
            self.authorization = .basic(user: user, password: password)
            return self
        }

        @discardableResult open func setBearerAuthorization(token: String) -> Self {
            self.authorization = .bearer(token: token)
            return self
        }

        @discardableResult open func setCustomAuthorization(_ authorization: String) -> Self {
            self.authorization = .custom(authorization)
            return self
        }

        public func build() -> LeafRequest {
            return LeafRequest(self)
        }

    }

    public func builder() -> Builder {
        return LeafRequest.builder(self)
    }

    public static func builder(_ leafRequest: LeafRequest) -> Builder {
        return Builder(leafRequest)
    }

    public static func builder(_ urlRequest: URLRequest) -> Builder? {
        return Builder(urlRequest)
    }

    public static func builder(_ url: URL) -> Builder {
        return Builder(url)
    }

    public static func builder(_ urlString: String) -> Builder? {
        return Builder(urlString)
    }

    public init(_ builder: Builder) {
        self.init(builder.url, cache: builder.cache ?? .useProtocolCachePolicy, timeout: builder.timeout ?? 60, mainDocumentURL: builder.mainDocumentURL, serviceType: builder.serviceType ?? .default, contentType: builder.contentType, contentLength: builder.contentLength, accept: builder.accept, acceptEncoding: builder.acceptEncoding, cacheControl: builder.cacheControl, allowsCellularAccess: builder.allowsCellularAccess ?? true, method: builder.method ?? .GET, headers: builder.headers, body: builder.body, bodyStream: builder.bodyStream, handleCookies: builder.handleCookies ?? true, usePipelining: builder.usePipelining ?? true, authorization: builder.authorization ?? .none)
    }
}

extension LeafRequest.Builder {

    fileprivate func query(_ parameters: [String: Any]) -> String {
        var components = [(String, String)]()

        for key in parameters.keys.sorted(by: <) {
            if let value = parameters[key] {
                components += queryComponents(key, value: value)
            }
        }

        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    fileprivate func queryComponents(_ key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (dictionaryKey, value) in dictionary {
                components += queryComponents("\(key)[\(dictionaryKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents("\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if CFBooleanGetTypeID() == CFGetTypeID(value) {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    fileprivate func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }

}
