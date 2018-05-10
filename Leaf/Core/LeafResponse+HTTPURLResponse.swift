//
//  LeafResponse+HTTPURLResponse.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension LeafResponse {

    public init(_ httpResponse: HTTPURLResponse, _ leafTask: LeafTask? = nil, _ responseObject: Any? = nil) {
        self.init(httpResponse.url, mimeType: httpResponse.mimeType, contentLength: httpResponse.expectedContentLength, textEncoding: httpResponse.textEncodingName, filename: httpResponse.suggestedFilename, statusCode: httpResponse.statusCode, headers: httpResponse.allHeaderFields, localizedDescription: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), leafTask: leafTask, responseObject: responseObject, response: httpResponse)
    }

}
