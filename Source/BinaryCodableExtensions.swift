/// Implementations of BinaryCodable for built-in types.

import Foundation


extension Array: BinaryEncodable where Element: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder, prefixLenght: Bool = true) throws {
        if prefixLenght {
            guard let count32 = UInt32(exactly: self.count) else {
                throw BinaryEncoder.Error.lenghtOutOfRange(UInt64(self.count))
            }
            try encoder.encode(count32)
        }
        for element in self {
            try (element).encode(to: encoder)
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
    public func binaryEncode(to encoder: BinaryEncoder, prefixLenght: Bool = true) throws {
        try Array(self.utf8).binaryEncode(to: encoder)
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

/*
extension SIMD where Self.MaskStorage.Scalar: BinaryDecodable {
    
}
 */

extension FixedWidthInteger where Self: BinaryEncodable {
    public func binaryEncode(to encoder: BinaryEncoder) {
        encoder.appendBytes(of: self.littleEndian)
    }
}

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
