//
//  RelationshipObjectSchema.swift
//  Tablelist
//
//  Created by Andrew Barba on 9/9/15.
//  Copyright © 2016 Tablelist, Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Realm
import SwiftyJSON


//public protocol TransformType {
//    associatedtype Object
//    associatedtype JSON
//    
//    func transformFromJSON(_ value: Any?) -> Object?
//    func transformToJSON(_ value: Object?) -> JSON?
//}

/**
 Safely map an Object onto a realm object
 */
public struct ObjectTransform<T: APIObject>: TransformType {
    
    public typealias JSON = AnyObject

    public typealias Object = APIObject

    
    /**
     * Existing value
     */
    private let existing: T?
    
    /**
     Initialization
     */
    public init(_ existing: T?) {
        self.existing = existing
    }
    
    /**
     Map from JSON
     */
    public func transformFromJSON(value: AnyObject?) -> T? {
        switch value {
        case let value as [String: AnyObject]:
            return existing?.extend(JSON: value) ?? Object(JSON: value) as! T
        case .some(let value):
            let json = ["value": value]
            return existing?.extend(JSON: json) ?? Object(JSON: json) as! T
        default:
            return nil
        }
    }
    
    /**
     Map to JSON
     */
    public func transformToJSON(value: T?) -> AnyObject? {
        guard let value = value else { return nil }
        return value.toJSON()
    }
}

/**
 Safely map an APIObject onto a realm object
 */
public struct APIObjectTransform<T: APIObject>: TransformType {
    
    /**
     * Existing value
     */
    private let existing: T?
    
    /**
     Dicates wheather we turn the object into a full JSON object or just the id
     */
    private let retainNestedStructure: Bool
    
    /**
     Initialization
     */
    public init(_ existing: T? = nil, retainNestedStructure: Bool = false) {
        self.existing = existing
        self.retainNestedStructure = retainNestedStructure
    }
    
    /**
     Map from JSON
     */
    public func transformFromJSON(value: AnyObject?) -> T? {
        let realm = try! Realm()
        switch value {
        case let value as String:
            return ObjectManager<T>().createOrUpdate(realm, objectID: value, json: SwiftyJSON.JSON([ObjectPrimaryKey: value]))
        case let value as [String: AnyObject]:
            let json = SwiftyJSON.JSON(value)
            guard let objectID = json.objectID else { return nil }
            return ObjectManager<T>().createOrUpdate(realm, objectID: objectID, json: json)
        default:
            return nil
        }
    }
    
    /**
     Map to JSON
     */
    public func transformToJSON(value: T?) -> AnyObject? {
        guard let value = value else { return nil }
        
        switch retainNestedStructure {
        case true:
            var json = value.toJSON()
            json[ObjectPrimaryKey] = value.id
            return json
        case false:
            return value.id
        }
    }
}
