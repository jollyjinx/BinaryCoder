//
//  SharedBinaryCoding.swift
//  
//
//  Created by Alessio Nossa on 25/11/20.
//

import Foundation

internal class BinaryContainer {
    
    var data: [AnyByteContainer] = []
    
    var count: Int {
        get {
            return self.data.count
        }
    }
    
    var type: ContainerType
    
    enum ContainerType: Equatable {
        case fixed
        case variable(registerSize: Bool = true, size: UInt32 = 0)
        
        static func ==(lhs: ContainerType, rhs: ContainerType) -> Bool {
            switch (lhs, rhs) {
            case (.variable, .variable):
                return true
            case (.fixed, .fixed):
                return true
            default:
                return false
            }
        }
    }
    
    init(type: ContainerType) {
        self.type = type
    }
    
    public func add(_ value: AnyByteContainer) {
        self.data.append(value)
    }
    
    public func incrementSize(_ increment: UInt32) {
        let oldType = self.type
        if case let BinaryContainer.ContainerType.variable(registerSize: register, size: size) = oldType {
            let newSize = size + increment
            self.type = BinaryContainer.ContainerType.variable(registerSize: register, size: newSize)
        }
    }
}

protocol AnyByteContainer {}

extension Array: AnyByteContainer where Element == UInt8 {}

extension BinaryContainer: AnyByteContainer {}


//===----------------------------------------------------------------------===//
// Shared Key Types
//===----------------------------------------------------------------------===//

internal struct _BinaryKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = _BinaryKey(stringValue: "super")!
}

/// A wrapper for fixed size sequences.
internal struct _FixedCodingKey: CodingKey {
  internal let stringValue: String
  internal let intValue: Int?

  internal init?(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = Int(stringValue)
  }

  internal init?(intValue: Int) {
    self.stringValue = "\(intValue)"
    self.intValue = intValue
  }
}
