//
//  RxMoyaProviderType+Cache.swift
//  MoyaMapper
//
//  Created by LinXunFeng on 2018/9/26.
//

import Moya
import RxSwift
#if !COCOAPODS
import RxMoya
import CacheMoyaMapper
#endif

public extension Reactive where Base: MoyaProviderType {
    func cacheRequest(
        _ target: Base.Target,
        cacheOnly: Bool? = nil, // nil: 先读取缓存再请求网络, true: 仅读缓存, false: 仅请求网络
        callbackQueue: DispatchQueue? = nil,
        cacheType: MMCache.CacheKeyType = .default
    ) -> Observable<Response> {
        var originRequest = request(target, callbackQueue: callbackQueue).asObservable()
        var cacheResponse: Response? = nil
        
        if cacheOnly != false { // cacheOnly 为 true 或 nil 时，尝试读取缓存
            cacheResponse = MMCache.shared.fetchResponseCache(target: target, cacheKey: cacheType)
        }

        if cacheOnly == true, let cached = cacheResponse {
            return Observable.just(cached) // 仅返回缓存
        } else if cacheOnly == false {
            // 仅执行网络请求
            return originRequest.map { response in
                if let resp = try? response.filterSuccessfulStatusCodes() {
                    MMCache.shared.cacheResponse(resp, target: target, cacheKey: cacheType)
                }
                return response
            }
        }

        // 默认行为（cacheOnly == nil）：先返回缓存，再执行网络请求
        if let cached = cacheResponse {
            return Observable.just(cached).concat(originRequest.map { response in
                if let resp = try? response.filterSuccessfulStatusCodes() {
                    MMCache.shared.cacheResponse(resp, target: target, cacheKey: cacheType)
                }
                return response
            })
        } else {
            return originRequest.map { response in
                if let resp = try? response.filterSuccessfulStatusCodes() {
                    MMCache.shared.cacheResponse(resp, target: target, cacheKey: cacheType)
                }
                return response
            }
        }
    }
}
