//
//  IncomingCallViewController.swift
//  PeerClientApp
//
//  Created by Akira Murao on 2017/04/11.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import UIKit
import PeerClient


class IncomingCallViewController: UIViewController, PeerDelegate {

    let showVideoViewSegue = "showVideoView"
    let backToContactsViewFromIncomingCallSegue = "backToContactsViewFromIncomingCall"

    @IBOutlet weak var callLabel: UILabel!
    @IBOutlet weak var peerIdLabel: UILabel!

    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!


    var peer: Peer?
    var callInfo: CallInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.answerButton.layer.cornerRadius = self.answerButton.frame.size.height / 2
        self.answerButton.clipsToBounds = true

        self.declineButton.layer.cornerRadius = self.declineButton.frame.size.height / 2
        self.declineButton.clipsToBounds = true

        if let connection = self.callInfo?.incomingConnection {
            self.callLabel.text = "Incoming call from"
            self.peerIdLabel.text = "\(connection.peerId)"
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        print(segue.identifier ?? "")

        if segue.identifier == self.showVideoViewSegue {
            if let vc = segue.destination as? VideoViewController {
                vc.peer = self.peer
                vc.peer?.delegate = vc

                vc.callInfo = self.callInfo
            }
        }
        else if segue.identifier == self.backToContactsViewFromIncomingCallSegue {
            if let vc = segue.destination as? ContactsViewController {
                vc.peer?.delegate = vc
            }
        }
    }

    // MARK: actions
    
    @IBAction func answerButtonPressed(sender: UIButton) {
        self.performSegue(withIdentifier: showVideoViewSegue, sender: self)
    }

    @IBAction func declineButtonPressed(sender: UIButton) {
        self.performSegue(withIdentifier: backToContactsViewFromIncomingCallSegue, sender: self)
    }

    // MARK: PeerPeerDelegate
    
    func peer(_ peer: Peer, didClose peerId: String?) {
        print("peer didClose peerId: \(peerId ?? "")")

//        self.performSegue(withIdentifier: self.backToMainViewSegue, sender: self)
    }

    func peer(_ peer: Peer, didReceiveError error: Error?) {

    }

    func peer(_ peer: Peer, didReceiveConnection connection: PeerConnection) {
/*
        self.callInfo = CallInfo(peerConnection: connection)
        self.performSegue(withIdentifier: self.showCallViewSegue, sender: self)
 */
    }

    func peer(_ peer: Peer, didCloseConnection connection: PeerConnection) {
        self.performSegue(withIdentifier: backToContactsViewFromIncomingCallSegue, sender: self)
    }

    func peer(_ peer: Peer, didReceiveRemoteStream stream: MediaStream) {

    }

    func peer(_ peer: Peer, didReceiveData data: Data) {
        
    }

    func peer(_ peer: Peer, didUpdatePeerIds peerIds: [String]) {

    }

}
