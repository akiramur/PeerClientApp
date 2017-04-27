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

    static let peerId: String = "myid0123"
    static let host: String = "put your peerjs server url"
    static let path: String = "/"
    static let port: Int = 443
    static let key: String = "put your peerjs server key"
    static let secure: Bool = true

    static let stun = PeerIceServerOptions(url: "stun:stun.l.google.com:19302", username: "", credential: "")
    static let turn = PeerIceServerOptions(url: "turn:turn.bistri.com:80", username: "homeo", credential: "homeo")
    static let iceServerOptions: [PeerIceServerOptions] = [stun, turn]

    static let herokuPingInterval: TimeInterval = 45.0
}
