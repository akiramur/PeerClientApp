//
//  Configuration.swift
//  PeerClientApp
//
//  Created by Akira Murao on 2017/03/30.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import Foundation
import PeerClient

struct Configuration {

    static let host: String = "m12.cloudmqtt.com"
    static let port: UInt16 = 11201
    static let username: String = "your username"
    static let password: String = "your password"
    static let keepAlive: UInt16 = 60

    static let stun = PeerIceServerOptions(url: "stun:stun.l.google.com:19302", username: "", credential: "")
    static let turn = PeerIceServerOptions(url: "turn:turn.bistri.com:80", username: "homeo", credential: "homeo")
    static let iceServerOptions: [PeerIceServerOptions] = [stun, turn]
}
