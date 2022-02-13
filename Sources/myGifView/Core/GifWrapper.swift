//
//  GifWrapper.swift
//  
//
//  Created by Syed Saud Arif on 13/02/22.
//

import Foundation

private let gifWrapperUserInfo: [String : Any] = [
    NSLocalizedDescriptionKey :  "Optional data object provided is nil." ,
    NSLocalizedFailureReasonErrorKey : "Optional data object provided is nil."]

public protocol GifWrapper {
    func getImageData() -> Result<Data, Error>
}


extension URL : GifWrapper {
    public func getImageData() -> Result<Data, Error> {
        return GifReader.getDataFrom(self)
    }
}

extension Data : GifWrapper {
    public func getImageData() -> Result<Data, Error> {
        return .success(self)
    }
}

extension Optional : GifWrapper where Wrapped == Data {
    public func getImageData() -> Result<Data, Error> {
        switch self {
        case .some(let data) :
            return .success(data)
        case .none :
            return .failure(NSError.init(domain: "SSASwiftUIGifView", code: 400, userInfo: gifWrapperUserInfo) )
        }
    }
}
