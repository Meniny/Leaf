//
//  LeafResponse+URLResponse.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension LeafResponse {

    public init(_ response: URLResponse, _ leafTask: LeafTask? = nil, _ responseObject: Any? = nil) {
        self.init(response.url, mimeType: response.mimeType, contentLength: response.expectedContentLength, textEncoding: response.textEncodingName, filename: response.suggestedFilename, leafTask: leafTask, responseObject: responseObject, response: response)
    }
    
}
