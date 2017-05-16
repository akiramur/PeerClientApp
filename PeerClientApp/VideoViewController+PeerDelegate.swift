//
//  VideoViewController+PeerDelegate.swift
//  PeerClientApp
//
//  Created by Akira Murao on 2017/04/11.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import Foundation
import PeerClient

extension VideoViewController: PeerDelegate {

    // MARK: PeerPeerDelegate
    
    func peer(_ peer: Peer, didClose peerId: String?) {
        print("peer didClose peerId: \(peerId ?? "")")

        // TODO: back to contact view?
    }

    func peer(_ peer: Peer, didReceiveError error: Error?) {
        // TODO: what to do?
    }

    func peer(_ peer: Peer, didReceiveConnection connection: PeerConnection) {
        print("peer didReceiveConnection \(String(describing: connection))")

        self.answer(connection: connection)
    }

    func peer(_ peer: Peer, didCloseConnection connection: PeerConnection) {

        print("peer didCloseConnection \(String(describing: connection))")

        if connection.connectionType == .media {
            self.mediaState = .disconnected
        }
        else if connection.connectionType == .data {
            self.dataState = .disconnected
        }
    }

    func peer(_ peer: Peer, didReceiveRemoteStream stream: MediaStream) {
        print("peer didReceiveRemoteStream \(String(describing: stream))")

        self.setupRemoteMediaStream(stream)
    }

    func peer(_ peer: Peer, didReceiveData data: Data) {

        print("peer didReceive data")
        
        self.particleViewController?.draw(data)
    }

    func peer(_ peer: Peer, didUpdatePeerIds peerIds: [String]) {
        
    }

}
