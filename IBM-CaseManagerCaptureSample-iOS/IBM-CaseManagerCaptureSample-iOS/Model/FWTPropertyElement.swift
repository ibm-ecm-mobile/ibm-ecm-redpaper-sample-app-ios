//
//  FWTPropertyElement.swift
//  IBM-CaseManagerCaptureSample-iOS
//
//  Copyright © 2015 IBM. All rights reserved.
//

import Foundation

struct FWTPropertyElement {
    let property:ICMProperty
    var value:NSObject?
    
    init(property:ICMProperty) {
        self.property = property
        self.value = self.property.value
    }
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

extension FWTPropertyElement {
    func dictionary() -> [String:NSObject!] {
        return [property.identifier : value]
    }
}

/// Simple `ErrorType` to inform that a required property needs its value
enum ElementError:ErrorType {
    case EmptyRequiredProperty(property:ICMProperty)
}

extension SequenceType where Generator.Element == FWTPropertyElement {
    /// Encapsulate the mutability of the dictionary create to parse the model into [identifier:value]
    func dictionary() throws -> [String:AnyObject] {
        var propertiesDictionary:[String:AnyObject] = [:]
        do {
            try forEach {
                if $0.value == nil && $0.property.required {
                    throw ElementError.EmptyRequiredProperty(property: $0.property)
                }
                
                if $0.value != nil && !$0.property.readOnly {
                    propertiesDictionary.merge($0.dictionary())
                }
            }
        } catch let error {
            throw error
        }
        return propertiesDictionary
    }
}