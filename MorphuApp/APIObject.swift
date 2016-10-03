//
//  APIObject.swift
//  Colorue
//
//  Created by Dylan Wight on 9/26/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Realm

public class APIObject: Object, Mappable {
    
    /**
     Applies the given JSON onto this object
     */
    public func extend(JSON: [String: AnyObject]) -> Self {
        Mapper().map(JSON: JSON, toObject: self)
        return self
    }
    
    /**
     Initialization
     */
    public required init(JSON: [String: AnyObject]) {
        super.init()
        extend(JSON: JSON)
    }
    
    /**
     Initialization
     */
    public required init(map: Map) {
        super.init()
    }
    
    /**
     Initialization
     */
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    /**
     Initialization
     */
    public required init() {
        super.init()
    }
    
    /**
     Initialization
     */
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    public func mapping(map: Map) {
        // override
    }
}

