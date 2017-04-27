//
//  ParticleData.swift
//  PeerClient
//
//  Created by Akira Murao on 9/19/15.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import Foundation

class ParticleData {
    
    enum EventType: UInt32 {
        case None
        case TouchBegin             = 1
        case TouchMove              = 2
        case TouchEnd               = 3
    }
    
    var eventType: EventType
    var byteArray: [UInt8]!
    
    init() {
        self.eventType = .None
        self.byteArray = nil
    }

    init(data: Data) {
        
        let count = data.count / MemoryLayout<UInt8>.size
        var bytes = [UInt8](repeating: 0, count: count)

        data.copyBytes(to: &bytes, count: count*MemoryLayout<UInt8>.size)

        self.eventType = .None
        self.byteArray = bytes
        
        self.eventType = self.eventTypeFromByteArray(bytes: self.byteArray)
    }
    
    init(event: EventType, x: Double, y: Double) {
        
        self.eventType = event
        switch event {
        case .TouchBegin, .TouchMove, .TouchEnd:
            self.byteArray = self.byteArrayFromTapEvent(event: self.eventType.rawValue, x: x, y: y)

        default:
            break
        }
    }
    
    // MARK: public
    
    func touchEvent() -> (event: UInt32, x: Double, y: Double) {
        return self.touchEventFromByteArray(value: self.byteArray)
    }

    // MARK: private

    private func eventTypeFromByteArray(bytes: [UInt8]) -> EventType {
        
        var et: EventType = .None
        
        if bytes.count > 4 {
            let eventBytes = Array(byteArray[0...3])
            let eventRawValue: UInt32 = self.fromByteArray(eventBytes, UInt32.self)
            et = EventType(rawValue: eventRawValue) ?? .None
        }
        
        return et
    }
    
    private func byteArrayFromTapEvent(event: UInt32, x: Double, y: Double) -> [UInt8] {
        var bytes: [UInt8] = []
        
        let eventBytes = self.toByteArray(event)
        bytes += eventBytes
        
        let xBytes = self.toByteArray(x)
        bytes += xBytes
        
        let yBytes = self.toByteArray(y)
        bytes += yBytes
        
        return bytes
    }

    private func touchEventFromByteArray(value: [UInt8]) -> (event: UInt32, x: Double, y: Double) {
        
        let eventBytes = Array(value[0...3])
        let event = self.fromByteArray(eventBytes, UInt32.self)
        
        let xBytes = Array(self.byteArray[4...11])
        let x = self.fromByteArray(xBytes, Double.self)
        
        let yBytes = Array(self.byteArray[12...19])
        let y = self.fromByteArray(yBytes, Double.self)
        
        return (event, x, y)
    }

    private func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }

    func fromByteArray<T>(_ bytes: [UInt8], _: T.Type) -> T {
        return bytes.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
}
