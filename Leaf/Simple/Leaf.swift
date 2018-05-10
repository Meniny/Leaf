
import Foundation
//import Leaf

// MARK: - Enums

public enum LeafDispatch {
    case asynchronously
    case synchronously
}

public enum LeafBodyType {
    case string(String, encoding: String.Encoding, lossy: Bool)
//    case json(Encodable)
//    case plist(Encodable)
    case jsonObject([String: Any], options: JSONSerialization.WritingOptions)
    case plistObject([String: Any], format: PropertyListSerialization.PropertyListFormat, options: PropertyListSerialization.WriteOptions)
    case stream(InputStream)
    case multipartFormData(LeafMultipartFormData)
    case custom(Data, LeafContentType)
}

public struct Leaf {
    public var session: LeafURLSession = LeafURLSession.init()
    
    public var requestURL: URL
    public var parameters: [String: Any]?
    public var headerFields: [String: String]?
    public var cachePolicy: LeafRequest.LeafCachePolicy
    public var customBody: LeafBodyType?
    
    public init?(_ aURLString: String,
                 parameters: [String: Any]?,
                 headers: [String: String]? = nil,
                 cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                 body: LeafBodyType? = nil) {
        guard let u = URL.init(string: aURLString) else {
            return nil
        }
        self.requestURL = u
        self.parameters = parameters
        self.headerFields = headers
        self.cachePolicy = cachePolicy
        self.customBody = body
    }
    
    public init(_ aURL: URL,
                parameters: [String: Any]?,
                headers: [String: String]? = nil,
                cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                body: LeafBodyType? = nil) {
        
        self.requestURL = aURL
        self.parameters = parameters
        self.headerFields = headers
        self.cachePolicy = cachePolicy
        self.customBody = body
    }
}

//// MARK: - Methods - Requests
public extension Leaf {
    @discardableResult
    public func request(_ dispatch: LeafDispatch,
                        method: LeafRequest.LeafMethod,
                        timeout: TimeInterval = 120,
                        progress: LeafTask.ProgressClosure? = nil,
                        success: LeafTask.SuccessClosure?,
                        failure: LeafTask.FailureClosure?) throws -> Leaf {
        
        let builder = try LeafRequest.init(self.requestURL).builder()
        builder.setMethod(method)
            .setURLParameters(self.parameters)
            .setTimeout(timeout)
            .setHeaders(self.headerFields)
            .setCache(self.cachePolicy)
        
        if let body = self.customBody {
            switch body {
            case .custom(let data, let contentType):
                builder.setCustomBody(data, contentType: contentType)
                break
            case .string(let string, let encoding, let lossy):
                builder.setStringBody(string, encoding: encoding, allowLossyConversion: lossy)
                break
            case .stream(let stream):
                builder.setBodyStream(stream)
                break
            case .jsonObject(let json, let options):
                try builder.setJSONBody(json, options: options)
                break
//            case .json(let json):
//                try builder.setJSONObject(json as? Encodable)
//            break
            case .plistObject(let plist, let format, let options):
                try builder.setPlistBody(plist, format: format, options: options)
                break
//            case .plist(let plist):
//                try builder.setPlistObject(plist as? Encodable)
//            break
            case .multipartFormData(let data):
                try builder.setMultipartFormData(data)
                break
            }
        }
        
        let task = self.session.dataTask(builder.build()).progress(progress)
        
        switch dispatch {
        case .asynchronously:
            task.async(success: success, failure: failure)
            break
        case .synchronously:
            do {
                success?(try task.sync())
            } catch {
                if let le = error as? LeafError {
                    failure?(le)
                } else {
                    failure?(LeafError.leafError(from: error))
                }
            }
            break
        }
        
        return self
    }
}

//// MARK: - Static Methods - Requests
public extension Leaf {
    @discardableResult
    public static func request(_ url: URL,
                               _ dispatch: LeafDispatch,
                               method: LeafRequest.LeafMethod,
                               parameters: [String: Any]?,
                               headers: [String: String]? = nil,
                               cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                               timeout: TimeInterval = 120,
                               body bodyType: LeafBodyType? = nil,
                               progress: LeafTask.ProgressClosure? = nil,
                               success: LeafTask.SuccessClosure?,
                               failure: LeafTask.FailureClosure?) throws -> Leaf {
        return try Leaf.init(url, parameters: parameters, headers: headers, cachePolicy: cachePolicy, body: bodyType).request(dispatch, method: method, timeout: timeout, progress: progress, success: success, failure: failure)
    }
    
    @discardableResult
    public static func async(_ method: LeafRequest.LeafMethod,
                             _ url: URL,
                             parameters: [String: Any]?,
                             headers: [String: String]? = nil,
                             cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                             timeout: TimeInterval = 120,
                             body bodyType: LeafBodyType? = nil,
                             progress: LeafTask.ProgressClosure? = nil,
                             success: LeafTask.SuccessClosure?,
                             failure: LeafTask.FailureClosure?) throws -> Leaf {
        return try Leaf.init(url, parameters: parameters, headers: headers, cachePolicy: cachePolicy, body: bodyType).request(.asynchronously, method: method, timeout: timeout, progress: progress, success: success, failure: failure)
    }
    
    @discardableResult
    public static func sync(_ method: LeafRequest.LeafMethod,
                            _ url: URL,
                            parameters: [String: Any]?,
                            headers: [String: String]? = nil,
                            cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                            timeout: TimeInterval = 120,
                            body bodyType: LeafBodyType? = nil,
                            progress: LeafTask.ProgressClosure? = nil,
                            success: LeafTask.SuccessClosure?,
                            failure: LeafTask.FailureClosure?) throws -> Leaf {
        return try Leaf.init(url, parameters: parameters, headers: headers, cachePolicy: cachePolicy, body: bodyType).request(.synchronously, method: method, timeout: timeout, progress: progress, success: success, failure: failure)
    }
}
