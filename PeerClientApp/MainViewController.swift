//
//  MainViewController.swift
//  PeerClientApp
//
//  Created by Akira Murao on 9/9/15.
//  Copyright (c) 2017 Akira Murao. All rights reserved.
//

import UIKit
import MapKit
import PeerClient

class MainViewController: UIViewController, PeerDelegate {
    
    let showContactsViewSegue = "showContactsView"
    

    @IBOutlet weak var signInButton: UIButton!

    var _contactsButton: UIBarButtonItem?
    var contactsButton: UIBarButtonItem {
        get {
            if let button = self._contactsButton {
                return button
            }
            else {
                let button = UIBarButtonItem(title: "Contacts", style: .plain, target: self, action: #selector(contactsButtonPressed(sender:)))
                self._contactsButton = button

                return button
            }
        }
    }
    
    var videoViewController: VideoViewController?

    var statusBarOrientation: UIInterfaceOrientation = UIInterfaceOrientation.portrait

    var _peer: Peer?
    var peer: Peer? {
        get {
            if _peer == nil {
                let peerOptions = PeerOptions(key: Configuration.key, host: Configuration.host, path: Configuration.path, secure: Configuration.secure, port: Configuration.port, iceServerOptions: Configuration.iceServerOptions)
                peerOptions.keepAliveTimerInterval = Configuration.herokuPingInterval

                _peer = Peer(options: peerOptions, delegate: self)
            }

            return _peer
        }

        set {
            _peer = newValue
        }
    }

    enum SignInStatus {

        case signedOut
        case signingIn
        case signedIn
        case signingOut

        var string: String {
            switch self {
            case .signedOut:
                return "signed out"
            case .signingIn:
                return "signing in"
            case .signedIn:
                return "signed in"
            case .signingOut:
                return "signing out"
            }
        }
    }
    var signInStatus: SignInStatus {
        didSet {
            switch self.signInStatus {
            case .signingIn:
                if oldValue != .signingIn {
                    self.signInButton.setTitle("Signing In ...", for: .normal)
                    self.signInButton.isEnabled = false
                    self.navigationItem.rightBarButtonItem = nil
                }
            case .signedIn:
                if oldValue != .signedIn {
                    self.signInButton.setTitle("Sign Out", for: .normal)
                    self.signInButton.isEnabled = true
                    self.navigationItem.rightBarButtonItem = self.contactsButton

                    self.performSegue(withIdentifier: self.showContactsViewSegue, sender: self)
                }
            case .signedOut:
                if oldValue != .signedOut {
                    self.signInButton.setTitle("Sign In", for: .normal)
                    self.signInButton.isEnabled = true
                    self.navigationItem.rightBarButtonItem = nil
                    self.peer?.destroy({ [weak self] (error) in
                        print(error.debugDescription)
                        self?.peer = nil
                    })
                }
            case .signingOut:
                if oldValue != .signingOut {
                    self.signInButton.setTitle("Signing Out ...", for: .normal)
                    self.signInButton.isEnabled = false
                    self.navigationItem.rightBarButtonItem = nil
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {

        self.signInStatus = .signedOut

        super.init(coder:coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.statusBarOrientation = UIApplication.shared.statusBarOrientation

        self.connectToSignailingServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


    /*
    - (void)applicationWillResignActive:(UIApplication*)application {
        [self disconnect];
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        print(segue.identifier ?? "")
        
        if segue.identifier == self.showContactsViewSegue {
            
            if let vc = segue.destination as? ContactsViewController {
                vc.peer = self.peer
                vc.peer?.delegate = vc
            }
        }
    }

    // MARK: actions
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        print("Sign In button pressed")

        guard let peer = self.peer else {
            return
        }

        if peer.isOpen {
            self.disconnectFromSignailingServer()
        }
        else {
            self.connectToSignailingServer()
        }
    }

    @IBAction func contactsButtonPressed(sender: UIBarButtonItem) {
        print("Contacts button pressed")

        guard let peer = self.peer else {
            return
        }

        guard peer.isOpen else {
            return
        }

        self.performSegue(withIdentifier: self.showContactsViewSegue, sender: self)
    }

    @IBAction func mainViewReturnAction(for segue: UIStoryboardSegue) {
        print(segue.identifier ?? "")

        guard let peer = self.peer else {
            self.signInStatus = .signedOut
            return
        }

        guard peer.isOpen else {
            self.signInStatus = .signedOut
            return
        }

    }

    // MARK: Private

    func showAlertWithMessage(message: String?) {
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("OK button was tapped")
        }))
    }

    func connectToSignailingServer() {

        print("connectToSignailingServer")

        if self.peer == nil {
            let peerOptions = PeerOptions(key: Configuration.key, host: Configuration.host, path: Configuration.path, secure: Configuration.secure, port: Configuration.port, iceServerOptions: Configuration.iceServerOptions)
            peerOptions.keepAliveTimerInterval = Configuration.herokuPingInterval

            self.peer = Peer(options: peerOptions, delegate: self)
        }

        self.signInStatus = .signingIn
        self.peer?.open(nil) { [weak self] (result) in
            switch result {
            case let .success(peerId):
                self?.signInStatus = .signedIn
            case let .failure(error):
                print("Peer open failed error: \(error)")
                self?.signInStatus = .signedOut
            }
        }
    }

    func disconnectFromSignailingServer() {

        print("disconnectFromSignailingServer")

        self.signInStatus = .signingOut
        self.peer?.disconnect { [weak self] (error) in
            self?.signInStatus = .signedOut
        }
    }

    // MARK: PeerPeerDelegate

    func peer(_ peer: Peer, didOpen peerId: String?) {
        print("peer didOpen peerId: \(peerId ?? "")")

        self.signInStatus = .signedIn
    }

    func peer(_ peer: Peer, didClose peerId: String?) {
        print("peer didClose peerId: \(peerId ?? "")")
        self.signInButton.setTitle("Sign In", for: .normal)

        self.signInStatus = .signedOut
    }

    func peer(_ peer: Peer, didReceiveError error: Error?) {
        self.showAlertWithMessage(message: "\(String(describing: error))")
    }

    func peer(_ peer: Peer, didReceiveConnection connection: PeerConnection) {

    }

    func peer(_ peer: Peer, didCloseConnection connection: PeerConnection) {

    }

    func peer(_ peer: Peer, didReceiveRemoteStream stream: MediaStream) {

    }

    func peer(_ peer: Peer, didReceiveData data: Data) {

    }

}

