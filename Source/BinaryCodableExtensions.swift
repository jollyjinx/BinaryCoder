/// Implementations of BinaryCodable for built-in types.

import Foundation


extension Array: BinaryEncodable where Element: BinaryEncodable {
    
    public func binaryEncode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

extension Array: BinaryDecodable where Element: BinaryDecodable {
    
    public init(fromBinary decoder: BinaryDecoder, lenght: UInt32? = nil) throws {
        var count: UInt32! = lenght
        if count == nil {
            count = try decoder.decode(UInt32.self)
        }
        self.init()
        self.reserveCapacity(Int(count))
        for _ in 0 ..< count {
            let decoded = try Element.self.init(from: decoder)
            self.append(decoded)
        }
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        let count = try decoder.decode(UInt32.self)
        self.init()
        self.reserveCapacity(Int(count))
        for _ in 0 ..< count {
            let decoded = try Element.self.init(from: decoder)
            self.append(decoded)
        }
    }
}

extension String: BinaryCodable {
    
    public func binaryEncode(to encoder: Encoder) throws {
        let elementsArray = self.utf8
        var container = encoder.unkeyedContainer()
        //try container.encode(contentsOf: elementsArray)
        for element in elementsArray {
            try container.encode(element)
        }
    }
    
    public init(fromBinary decoder: BinaryDecoder, lenght: UInt32? = nil) throws {
        let utf8: [UInt8] = try Array(fromBinary: decoder, lenght: lenght)
        if let str = String(bytes: utf8, encoding: .utf8) {
            self = str
        } else {
            throw BinaryDecoder.Error.invalidUTF8(utf8)
        }
    }
    
    public init(fromBinary decoder: BinaryDecoder) throws {
        let utf8: [UInt8] = try Array(fromBinary: decoder)
        if let str = String(bytes: utf8, encoding: .utf8) {
            self = str
        } else {
            throw BinaryDecoder.Error.invalidUTF8(utf8)
        }
    }
}


extension SIMD where Self: BinaryDecodable {
    public init(fromBinary binaryDecoder: BinaryDecoder) throws {
        var v = Self.init()
        try binaryDecoder.read(into: &v)
        self = v
    }
}

/// A wrapper for dictionary keys which are Strings or Ints.
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

extension SIMD where Self: BinaryEncodable {
    
    public func binaryEncode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: _FixedCodingKey.self)
        for index in self.indices {
            let item = self[index]
            let key = _FixedCodingKey(intValue: index)!
            try container.encode(item, forKey: key)
        }
        //encoder.appendBytes(of: self)
    }
}

extension SIMD2: BinaryCodable where Self.MaskStorage.Scalar: FixedWidthInteger { }
extension SIMD4: BinaryCodable where Self.MaskStorage.Scalar: FixedWidthInteger { }
extension SIMD8: BinaryCodable where Self.MaskStorage.Scalar: FixedWidthInteger { }

/*
extension FixedWidthInteger where Self: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        encoder.appendBytes(of: self.littleEndian)
    }
}
 */

extension FixedWidthInteger where Self: BinaryDecodable {
    public init(fromBinary binaryDecoder: BinaryDecoder) throws {
        var v = Self.init()
        try binaryDecoder.read(into: &v)
        self.init(littleEndian: v)
    }
}

extension Int8: BinaryCodable {}
extension UInt8: BinaryCodable {}
extension Int16: BinaryCodable {}
extension UInt16: BinaryCodable {}
extension Int32: BinaryCodable {}
extension UInt32: BinaryCodable {}
extension Int64: BinaryCodable {}
extension UInt64: BinaryCodable {}
extension Float32: BinaryCodable {}
extension Float64: BinaryCodable {}
