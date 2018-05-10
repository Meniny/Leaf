//
//  LeafError.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

public enum LeafError: Error {
    case leaf(code: Int?, message: String, headers: [AnyHashable : Any]?, object: Any?, underlying: Error?)
    case parse(code: Int?, message: String, object: Any?, underlying: Error?)
    
    public var code: Int? {
        switch self {
        case .leaf(code: let c, message: _, headers: _, object: _, underlying: _):
            return c ?? _code
        case .parse(code: let c, message: _, object: _, underlying: _):
            return c ?? _code
        }
    }
    
    public var underlying: Error? {
        switch self {
        case .leaf(code: _, message: _, headers: _, object: _, underlying: let u):
            return u
        case .parse(code: _, message: _, object: _, underlying: let u):
            return u
        }
    }
    
    public var message: String? {
        switch self {
        case .leaf(code: _, message: let m, headers: _, object: _, underlying: _):
            return m ?? localizedDescription
        case .parse(code: _, message: let m, object: _, underlying: _):
            return m ?? localizedDescription
        }
    }
    
    public var headers: [AnyHashable : Any]? {
        switch self {
        case .leaf(code: _, message: _, headers: let h, object: _, underlying: _):
            return h
        default: return nil
        }
    }
}

extension LeafError {

    public func object<T>() throws -> T {
        switch self {
        case .leaf(let code, _, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try objectTransformation(code, object, underlying)
        }
    }

    public func decode<D: Decodable>() throws -> D {
        switch self {
        case .leaf(let code, _, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        case .parse(let code, _, let object, let underlying):
            return try decodeTransformation(code, object, underlying)
        }
    }

    private func objectTransformation<T>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> T {
        do {
            return try LeafTransformer.object(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func decodeTransformation<D: Decodable>(_ code: Int? = nil, _ object: Any? = nil, _ underlying: Error? = nil) throws -> D {
        do {
            return try LeafTransformer.decode(object: object)
        } catch {
            throw handle(error, code, underlying)
        }
    }

    private func handle(_ error: Error, _ code: Int? = nil, _ underlying: Error? = nil) -> Error {
        switch error as! LeafError {
        case .parse(let transformCode, let message, let object, let transformUnderlying):
            return LeafError.parse(code: transformCode ?? code, message: message, object: object, underlying: transformUnderlying ?? underlying)
        default:
            return error
        }
    }
    
}

extension LeafError {

    public var localizedDescription: String {
        switch self {
        case .leaf(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            if let localizedDescription = underlying?.localizedDescription, localizedDescription != message {
                return message + " " + localizedDescription
            }
            return message
        }
    }

}

extension LeafError: CustomStringConvertible {

    public var description: String {
        return localizedDescription
    }

}

extension LeafError: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .leaf(let code, _, _, _, _), .parse(let code, _, _, _):
            if let code = code?.description {
                return code + " " + localizedDescription
            }
            return localizedDescription
        }
    }
    
}

extension LeafError: CustomNSError {

    public var errorCode: Int {
        switch self {
        case .leaf(let code, _, _, _, _):
            return code ?? 0
        case .parse(let code, _, _, _):
            return code ?? 1
//        case .response(let code, _, _):
//            return code ?? 0
        }
    }

    public var errorUserInfo: [String : Any] {
        switch self {
        case .leaf(_, let message, _, _, let underlying), .parse(_, let message, _, let underlying):
            guard let underlying = underlying else {
                return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message]
            }
            return [NSLocalizedDescriptionKey: localizedDescription, NSLocalizedFailureReasonErrorKey: message, NSUnderlyingErrorKey: underlying]
        }
        
    }

}

public extension LeafError {
    public static func leafError(from error: Error) -> LeafError {
        return LeafError.leaf(code: error._code,
                                message: error.localizedDescription,
                                headers: nil,
                                object: nil,
                                underlying: error)
    }
    
    public static func parseError(from error: Error) -> LeafError {
        return LeafError.parse(code: error._code,
                                message: error.localizedDescription,
                                object: nil,
                                underlying: error)
    }
    
    public static var unknown: LeafError {
        return LeafError.leaf(code: 0, message: "Unknown", headers: nil, object: nil, underlying: nil)
    }
}
