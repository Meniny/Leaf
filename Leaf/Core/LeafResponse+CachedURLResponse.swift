//
//  LeafResponse+CachedURLResponse.swift
//  Leaf
//
//  Created by Elias Abel on 22/3/17.
//
//

import Foundation

extension LeafResponse {

    public init(_ cachedResponse: CachedURLResponse, _ leafTask: LeafTask? = nil) {
        self.init(cachedResponse.response.url, mimeType: cachedResponse.response.mimeType, contentLength: cachedResponse.response.expectedContentLength, textEncoding: cachedResponse.response.textEncodingName, filename: cachedResponse.response.suggestedFilename, userInfo: cachedResponse.userInfo, leafTask: leafTask, responseObject: cachedResponse.data, response: cachedResponse.response)
    }
    
}
