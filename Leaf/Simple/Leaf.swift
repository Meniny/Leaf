
import Foundation
//import Leaf

// MARK: - Enums

public enum LeafDispatch {
    case asynchronously
    case synchronously
}

public enum LeafBodyType {//: Equatable {
    case string(String, encoding: String.Encoding, lossy: Bool)
//    case json(Encodable)
//    case plist(Encodable)
    case jsonObject(Any, options: JSONSerialization.WritingOptions)
    case plistObject(Any, format: PropertyListSerialization.PropertyListFormat, options: PropertyListSerialization.WriteOptions)
    case stream(InputStream)
    case multipartFormData(LeafMultipartFormData)
    case custom(Data, LeafContentType)
    
//    public static func == (lhs: LeafBodyType, rhs: LeafBodyType) -> Bool {
//        switch (lhs, rhs) {
//        case let (.custom(a, b), .custom(c, d)):
//            return a == c && b == d
//        case let (.string(a, b, c), .string(d, e, f)):
//            return a == d && b == e && c == f
//        case let (.jsonObject(a, b), .jsonObject(c, d)):
//            return a == c && b == d
//        case let (.plistObject(a, b, c), .plistObject(d, e, f)):
//            return a == d && b == e && c == f
//        default:
//            return false
//        }
//    }
}

public struct Leaf {
//public struct Leaf: Equatable {
//    public static func == (lhs: Leaf, rhs: Leaf) -> Bool {
//        return lhs.session == rhs.session &&
//        lhs.requestURL == rhs.requestURL &&
//        lhs.headerFields == rhs.headerFields &&
//        lhs.parameters == rhs.parameters &&
//        lhs.cachePolicy == rhs.cachePolicy &&
//        lhs.customBody == rhs.customBody
//    }

    public static var leafs = [String: Leaf]()
    
    public let session: LeafURLSession
    
    public let requestURL: URL
    public let parameters: [String: Any]?
    public let headerFields: [String: String]?
    public let cachePolicy: LeafRequest.LeafCachePolicy
    public let customBody: LeafBodyType?
    
    public init?(_ aURLString: String,
                 parameters: [String: Any]?,
                 headers: [String: String]? = nil,
                 cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                 body: LeafBodyType? = nil,
                 session: LeafURLSession = LeafURLSession.init()) {
        guard let u = URL.init(string: aURLString) else {
            return nil
        }
        self.requestURL = u
        self.parameters = parameters
        self.headerFields = headers
        self.cachePolicy = cachePolicy
        self.customBody = body
        self.session = session
    }
    
    public init(_ aURL: URL,
                parameters: [String: Any]?,
                headers: [String: String]? = nil,
                cachePolicy: LeafRequest.LeafCachePolicy = .reloadIgnoringLocalCacheData,
                body: LeafBodyType? = nil,
                session: LeafURLSession = LeafURLSession.init()) {
        
        self.requestURL = aURL
        self.parameters = parameters
        self.headerFields = headers
        self.cachePolicy = cachePolicy
        self.customBody = body
        self.session = session
    }
    
    internal func build(method: LeafRequest.LeafMethod, timeout: TimeInterval) throws -> LeafRequest {
        let builder = try LeafRequest.init(self.requestURL).builder()
        builder.setMethod(method)
        builder.setURLParameters(self.parameters)
        builder.setTimeout(timeout)
        builder.setHeaders(self.headerFields)
        builder.setCache(self.cachePolicy)
        
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
        return builder.build()
    }
    
    @discardableResult
    public func request(_ dispatch: LeafDispatch,
                        method: LeafRequest.LeafMethod,
                        timeout: TimeInterval = 120,
                        progress: LeafTask.ProgressClosure? = nil,
                        success: LeafTask.SuccessClosure?,
                        failure: LeafTask.FailureClosure?) throws -> Leaf {
        
        let request = try self.build(method: method, timeout: timeout)
        let task = self.session.dataTask(request)
        task.progress(progress)
        
        let k = dumping(self)
        Leaf.leafs[k] = self
        
        switch dispatch {
        case .asynchronously:
            task.async(success: {
                success?($0)
                Leaf.leafs.removeValue(forKey: k)
            }, failure: {
                failure?($0)
                Leaf.leafs.removeValue(forKey: k)
            })
            break
        case .synchronously:
            do {
                let response = try task.sync()
                success?(response)
            } catch {
                if let le = error as? LeafError {
                    failure?(le)
                } else {
                    let le = LeafError.leafError(from: error)
                    failure?(le)
                }
            }
            Leaf.leafs.removeValue(forKey: k)
            break
        }
        
        return self
    }
}

public func dumping(_ item: Any?) -> String {
    var output = ""
    guard let i = item else {
        dump(item, to: &output)
        return output
    }
    dump(i, to: &output)
    return output
}
