//
//  MMCache.swift
//  MoyaMapper
//
//  Created by LinXunFeng on 2018/9/26.
//  Copyright © 2018年 LinXunFeng. All rights reserved.
//

import Cache
import Moya
import SwiftyJSON

fileprivate struct CacheName {
    static let MoyaResponse = "MMCache.lxf.MoyaResponse"
    static let JSON = "MMCache.lxf.JSON"
}

public struct MMCache {
    public static let shared = MMCache()
    private init() {}
    
    public enum CacheContainer {
        case RAM
        case hybrid
    }
    
    internal let boolRAMStorage = MemoryStorage<String, Bool>(config: MemoryConfig())
    internal let jsonRAMStorage = MemoryStorage<String, JSON>(config: MemoryConfig())
    
    internal let responseStorage = try? Storage<String, Moya.Response>(
        diskConfig: DiskConfig(name: CacheName.MoyaResponse),
        memoryConfig: MemoryConfig(),
        transformer: TransformerFactory.forResponse(Moya.Response.self)
    )
    
    internal let jsonStorage = try? Storage<String, JSON>(
        diskConfig: DiskConfig(name: CacheName.JSON),
        memoryConfig: MemoryConfig(),
        transformer: TransformerFactory.forJSON()
    )
}



