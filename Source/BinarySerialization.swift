//
//  BinarySerialiazation.swift
//  
//
//  Created by Alessio Nossa on 25/11/20.
//

import Foundation

internal class BinarySerialiazation {
    class func dataArray(with object: BinaryContainer) throws -> [UInt8] {
        return try extactData(object: object)
    }
    
    private class func extactData(object: BinaryContainer) throws -> [UInt8] {
        var bytes: [UInt8] = []
        for (_, child) in object.data.enumerated() {
            switch child {
            case let newBytes as [UInt8]:
                bytes.append(contentsOf: newBytes)
            case let container as BinaryContainer:
                var newChild: [UInt8] = []
                if case let .variable(registerSize: register, size: size) = container.type, register == true {
                    let lenght = self.getBytes(of: size)
                    newChild.append(contentsOf: lenght)
                }
                try newChild.append(contentsOf: extactData(object: container))
                
                bytes.append(contentsOf: newChild)
            default:
                throw BinaryEncoder.Error.unknowObjectType
            }
        }
        
        return bytes
    }
    
    /// Append the raw bytes of the parameter to the encoder's data. No byte-swapping
    /// or other encoding is done.
    private class func getBytes<T>(of: T) -> [UInt8] {
        let target = of
        let buffer = withUnsafeBytes(of: target) {
            return $0
        }
        return [UInt8].init(buffer)
    }
}
