//
//  ContactsViewController.swift
//  PeerClientApp
//
//  Created by Akira Murao on 9/18/15.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import UIKit
import PeerClient

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PeerDelegate {

    let showVideoViewSegue = "showVideoView"
    let showIncomingCallViewSegue = "showIncomingCallView"
    
    let destIdCellReuseIdentifier : String = "destIdCell"
    let backToMainViewSegue = "backToMainViewFromContacts"

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var destIdTableView: UITableView!
    
    var peer: Peer?
    var peerIds: [String]?
    
    var callInfo: CallInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.idField.text = self.peer?.peerId
        
        self.peer?.listAllPeers { [weak self] (result) -> Void in

            switch result {
            case let .success(peerIds):
                DispatchQueue.main.async {
                    var newPeerIds: [String] = []

                    for peerId in peerIds {
                        if peerId != self?.peer?.peerId {
                            newPeerIds.append(peerId)
                        }
                    }

                    self?.peerIds = newPeerIds
                    self?.destIdTableView.reloadData()
                }

            case .failure(_):
                DispatchQueue.main.async {
                    self?.peerIds = []
                    self?.destIdTableView.reloadData()
                }
            }
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
        else if segue.identifier == self.showIncomingCallViewSegue {
            if let vc = segue.destination as? IncomingCallViewController {
                vc.peer = self.peer
                vc.peer?.delegate = vc

                vc.callInfo = self.callInfo
            }
        }
        else if segue.identifier == self.backToMainViewSegue {
            if let vc = segue.destination as? MainViewController {
                vc.peer?.delegate = vc
            }
        }
        
        
    }

    // MARK: actions

    @IBAction func contactsViewReturnAction(for segue: UIStoryboardSegue) {
        print(segue.identifier ?? "")

        if let vc = segue.source as? IncomingCallViewController {
            print("returned from call view")
        }
        else if let vc = segue.source as? VideoViewController {
            print("returned from video view")
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = 0
        if let peerIds = self.peerIds {
            num = peerIds.count
        }
        
        return num
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: destIdCellReuseIdentifier, for: indexPath as IndexPath)
        
        if let peerIds = self.peerIds {
            cell.textLabel?.text = peerIds[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let peerIds = self.peerIds {
            self.callInfo = CallInfo(peerId: peerIds[indexPath.row])
            self.performSegue(withIdentifier: self.showVideoViewSegue, sender: self)
        }
    }

    // MARK: Private

    // MARK: PeerPeerDelegate

    func peer(_ peer: Peer, didOpen peerId: String?) {
        print("peer didOpen peerId: \(peerId ?? "")")
    }

    func peer(_ peer: Peer, didClose peerId: String?) {
        print("peer didClose peerId: \(peerId ?? "")")

        self.performSegue(withIdentifier: self.backToMainViewSegue, sender: self)
    }

    func peer(_ peer: Peer, didReceiveError error: Error?) {

    }

    func peer(_ peer: Peer, didReceiveConnection connection: PeerConnection) {

        self.callInfo = CallInfo(peerConnection: connection)
        self.performSegue(withIdentifier: self.showIncomingCallViewSegue, sender: self)
    }

    func peer(_ peer: Peer, didCloseConnection connection: PeerConnection) {

    }

    func peer(_ peer: Peer, didReceiveRemoteStream stream: MediaStream) {

    }

    func peer(_ peer: Peer, didReceiveData data: Data) {
        
    }

}
