//
//  File.swift
//  
//
//  Created by Eric Rabil on 12/21/21.
//

import Foundation

public enum MetadataValue: Codable, Hashable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, ExpressibleByBooleanLiteral, ExpressibleByNilLiteral, ExpressibleByStringInterpolation {
    public typealias BooleanLiteralType = Bool
    
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
    
    public init(stringLiteral: String) {
        self = .string(stringLiteral)
    }
    
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
    
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
    
    public init(dictionaryLiteral elements: (String, MetadataValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
    
    public init(arrayLiteral elements: MetadataValue...) {
        self = .array(elements)
    }
    
    public init(nilLiteral: ()) {
        self = .nil
    }
    
    public func merge(_ rhs: MetadataValue) -> MetadataValue {
        switch self {
        case .array(let values):
            if case .array(let moreValues) = rhs {
                return .array(values + moreValues)
            }
            break
        case .dictionary(let values):
            if case .dictionary(let moreValues) = rhs {
                if moreValues.keys.allSatisfy({ !values.keys.contains($0) }) {
                    return .dictionary(Dictionary(Array(values) + Array(moreValues), uniquingKeysWith: { key1, key2 in key1 }))
                }
            }
            break
        case .nil:
            return rhs
        default:
            break
        }
        
        return [self, rhs]
    }
    
    public typealias StringLiteralType = String
    public typealias IntegerLiteralType = Int
    public typealias FloatLiteralType = Double
    public typealias Key = String
    public typealias Value = MetadataValue
    public typealias ArrayLiteralElement = MetadataValue
    
    case `nil`
    case string(String)
    case int(Int)
    case double(Double)
    case boolean(Bool)
    case dictionary([String: MetadataValue])
    case array([MetadataValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            self = .array(try container.decode([MetadataValue].self))
        } catch {
            do {
                self = .dictionary(try container.decode([String: MetadataValue].self))
            } catch {
                do {
                    self = .string(try container.decode(String.self))
                } catch {
                    do {
                        self = .double(try container.decode(Double.self))
                    } catch {
                        do {
                            self = .int(try container.decode(Int.self))
                        } catch {
                            do {
                                self = .boolean(try container.decode(Bool.self))
                            } catch {
                                self = .nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    var encodable: Encodable {
        switch self {
        case .nil:
            return Optional<MetadataValue>.none
        case .string(let encodable as Encodable), .int(let encodable as Encodable), .double(let encodable as Encodable), .boolean(let encodable as Encodable), .dictionary(let encodable as Encodable), .array(let encodable as Encodable):
            return encodable
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        struct EncodingProxy: Encodable {
            let fn: (Encoder) throws -> ()
            
            init(_ fn: @escaping (Encoder) throws -> ()) {
                self.fn = fn
            }
            
            func encode(to encoder: Encoder) throws {
                try fn(encoder)
            }
        }
        
        var container = encoder.singleValueContainer()
        try container.encode(EncodingProxy(encodable.encode(to:)))
    }
    
    var hashable: AnyHashable {
        switch self {
        case .nil:
            return Optional<MetadataValue>.none as AnyHashable
        case .string(let hashable as AnyHashable), .int(let hashable as AnyHashable), .double(let hashable as AnyHashable), .boolean(let hashable as AnyHashable), .dictionary(let hashable as AnyHashable), .array(let hashable as AnyHashable):
            return hashable
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hashable.hash(into: &hasher)
    }
}
