//
//  VideoViewController.swift
//  PeerClientApp
//
//  Created by Akira Murao on 2017/04/06.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import AVFoundation
import UIKit
import PeerClient


class VideoViewController: UIViewController {

    let particleContainerViewEmbedSegue = "particleContainerView"
    let backToContactsViewFromVideoSegue = "backToContactsViewFromVideo"

    @IBOutlet weak var exitVideoViewButton: UIButton!
    @IBOutlet weak var remoteVideoContainerView: UIView!

    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var dataButton: UIButton!

    @IBOutlet weak var particleContainerView: UIView!
    
    var peer: Peer?
    var callInfo: CallInfo?
    
    // Padding space for local video view with its parent.
    let kLocalViewPadding: CGFloat = 10
    

    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting

        var string: String {
            switch self {
            case .disconnected:
                return "disconnected"
            case .connecting:
                return "connecting"
            case .connected:
                return "connected"
            case .disconnecting:
                return "disconnecting"
            }
        }

        var color: UIColor {
            switch self {
            case .disconnected:
                return UIColor.red
            case .connecting:
                return UIColor.yellow
            case .connected:
                return UIColor.green
            case .disconnecting:
                return UIColor.green
            }
        }
    }

    var mediaState: ConnectionState {
        didSet {
            //self.mediaButton.setImage(UIImage(named: self.mediaState.imageName), for: UIControlState.normal)
            //self.mediaStateLabel.text = self.mediaState.string
            self.mediaButton.backgroundColor = self.mediaState.color
            self.mediaButton.setTitle(self.mediaState.string, for: .normal)

            if self.mediaState == .disconnected {
                self.exitVideoViewIfNeeded()
            }
        }
    }

    var dataState: ConnectionState {
        didSet {
            //self.dataButton.setImage(UIImage(named: self.dataState.imageName), for: UIControlState.normal)
            //self.dataStateLabel.text = self.dataState.string
            self.dataButton.backgroundColor = self.dataState.color
            self.dataButton.setTitle(self.dataState.string, for: .normal)

            if self.dataState == .disconnected {
                self.exitVideoViewIfNeeded()
            }
        }
    }

    var localVideoView: EAGLVideoView!
    var remoteVideoView: EAGLVideoView!

    lazy var localVideoTrack: VideoTrack? = nil
    lazy var remoteVideoTrack: VideoTrack? = nil
    lazy var localVideoSize: CGSize = CGSize.zero
    lazy var remoteVideoSize: CGSize = CGSize.zero
    
    public lazy var particleViewController: ParticleViewController? = nil

    required init?(coder: NSCoder) {

        self.mediaState = .disconnected
        self.dataState = .disconnected

        super.init(coder:coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mediaButton.layer.cornerRadius = self.mediaButton.frame.size.height / 2
        self.mediaButton.clipsToBounds = true
        self.mediaState = .disconnected

        self.dataButton.layer.cornerRadius = self.dataButton.frame.size.height / 2
        self.dataButton.clipsToBounds = true
        self.dataState = .disconnected

        self.exitVideoViewButton.layer.cornerRadius = self.exitVideoViewButton.frame.size.height / 2
        self.exitVideoViewButton.clipsToBounds = true

        self.remoteVideoView = EAGLVideoView(frame: self.remoteVideoContainerView.bounds)
        self.remoteVideoView.delegate = self
        self.remoteVideoView.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.remoteVideoContainerView.addSubview(self.remoteVideoView)

        self.localVideoView = EAGLVideoView(frame: self.remoteVideoContainerView.bounds)
        self.localVideoView.delegate = self;
        self.remoteVideoContainerView.addSubview(self.localVideoView)


        self.particleContainerView.isUserInteractionEnabled = true


        if let peerId = self.callInfo?.callingPeerId {
            self.call(peerId: peerId)
        }
        else if let connection = self.callInfo?.incomingConnection {
            self.answer(connection: connection)
        }
        else {
            // TODO: go back to contact
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        print(segue.identifier ?? "")
        
        if segue.identifier == self.particleContainerViewEmbedSegue {
            if let vc = segue.destination as? ParticleViewController {
                vc.peer = self.peer
                
                self.particleViewController = vc
            }
        }
        else if segue.identifier == self.backToContactsViewFromVideoSegue {
            if let vc = segue.destination as? ContactsViewController {
                vc.peer?.delegate = vc
            }
        }
    }

    func resetUI() {
        print("resetUI")

        self.localVideoTrack?.removeVideoView(videoView: self.localVideoView)
        self.localVideoTrack = nil
        self.localVideoView.renderFrame()

        self.remoteVideoTrack?.removeVideoView(videoView: self.remoteVideoView)
        self.remoteVideoTrack = nil
        self.remoteVideoView.renderFrame()
    }

    func setupCaptureSession() {
        print("setupCaptureSession")
        self.updateVideoViewLayout()
    }

    func updateVideoViewLayout() {

        let defaultAspectRatio = CGSize(width: 3, height: 4)

        var localAspectRatio = self.localVideoSize
        if self.localVideoSize == CGSize.zero {
            localAspectRatio = defaultAspectRatio
        }
        var remoteAspectRatio = self.remoteVideoSize
        if self.remoteVideoSize == CGSize.zero {
            remoteAspectRatio = defaultAspectRatio
        }

        let remoteVideoFrame = AVMakeRect(aspectRatio: remoteAspectRatio, insideRect: self.remoteVideoContainerView.bounds)
        self.remoteVideoView.frame = remoteVideoFrame

        var localVideoFrame = AVMakeRect(aspectRatio: localAspectRatio, insideRect: self.remoteVideoContainerView.bounds);

        localVideoFrame.size.width = localVideoFrame.size.width / 3
        localVideoFrame.size.height = localVideoFrame.size.height / 3
        localVideoFrame.origin.x = self.remoteVideoContainerView.bounds.maxX - localVideoFrame.size.width - kLocalViewPadding
        localVideoFrame.origin.y = self.remoteVideoContainerView.bounds.maxY - localVideoFrame.size.height - kLocalViewPadding
        self.localVideoView.frame = localVideoFrame
    }

    // MARK: actions

    @IBAction func exitVideoViewButtonPressed(sender: UIButton) {

        guard let peer = self.peer else {
            // TODO: need to exit here?
            return
        }

        self.mediaState = .disconnecting
        self.dataState = .disconnecting
        peer.closeAllConnections { [weak self] (error) in
            print("peer closeConnection done \(error.debugDescription)")

            self?.mediaState = .disconnected
            self?.dataState = .disconnected
        }
    }

    @IBAction func mediaButtonPressed(sender: UIButton) {

        print("Media State button pressed")

        guard let peer = self.peer else {
            return
        }

        if peer.mediaConnections.count > 0 {
            self.mediaState = .disconnecting
            peer.closeConnections(.media, completion: { [weak self] (error) in
                print("peer closeConnection done \(error.debugDescription)")

                self?.mediaState = .disconnected
            })
        }
        else {
            // dataConnection must exist otherwise, go back to contacts view.
            guard peer.dataConnections.count > 0 else {
                return
            }

           // let peerId = dataConnection.peerId
            guard let peerId = self.callInfo?.destPeerId else {
                return
            }

            let factory = PeerConnectionFactory.sharedInstance
            guard let mediaStream = factory.createLocalMediaStream() else {
                print("To call a peer, you must provide a stream from your browser's getUserMedia.")
                return
            }

            self.mediaState = .connecting
            peer.call(peerId: peerId, mediaStream: mediaStream, completion: { [weak self] (result) in

                switch result {
                case .success(_):
                    print("call succeeded")

                    self?.setupCaptureSession()
                    self?.setupLocalMediaStream(mediaStream)
                    self?.mediaState = .connected

                case let .failure(error):
                    print("call failed: \(error)")
                    self?.mediaState = .disconnected
                }
            })
        }
    }

    @IBAction func dataButtonPressed(sender: UIButton) {

        print("Data State button pressed")

        guard let peer = self.peer else {
            return
        }

        if peer.dataConnections.count > 0 {

            self.dataState = .disconnecting
            peer.closeConnections(.data) { [weak self] (error) in
                self?.dataState = .disconnected
            }
        }
        else {
            // mediaConnection must exist otherwise, go back to contacts view.
            guard peer.mediaConnections.count > 0 else {
                return
            }

            // let peerId = mediaConnection.peerId
            guard let peerId = self.callInfo?.destPeerId else {
                return
            }

            self.dataState = .connecting
            peer.connect(peerId: peerId, completion: { [weak self] (result) in
                switch result {
                case .success(_):
                    self?.dataState = .connected

                case let .failure(error):
                    print("openDataConnection failed: \(error)")
                    self?.dataState = .disconnected
                }
            })
        }
    }

    // MARK: public

    // MARM: Media stream

    func setupLocalMediaStream(_ mediaStream: MediaStream) {
        print("setupLocalMediaStream")

        if let videoTrack = mediaStream.videoTracks.first {
            self.localVideoTrack = videoTrack
            videoTrack.addVideoView(videoView: self.localVideoView)
        }
    }

    // MARK: delete local video stream
    /*
     func deleteLocalMediaStream() {
     NSLog("deleteLocalMediaStream");

     if (self.localMediaStream != nil) && (self.localVideoTrack != nil) {
     self.localMediaStream?.removeVideoTrack(self.localVideoTrack)
     self.localVideoTrack = nil
     NSLog("local video track remove from media stream")
     }
     }
     */

    func setupRemoteMediaStream(_ mediaStream: MediaStream) {
        print("setupRemoteMediaStream")

        if let videoTrack = mediaStream.videoTracks.first {
            self.remoteVideoTrack = videoTrack
            videoTrack.addVideoView(videoView: self.remoteVideoView)
        }
    }

    
    // called when call selected in tableView item

    func call(peerId: String) {

        guard let peer = self.peer else {
            return
        }

        let factory = PeerConnectionFactory.sharedInstance
        guard let mediaStream = factory.createLocalMediaStream() else {
            print("To call a peer, you must provide a stream from your browser's getUserMedia.")
            return
        }

        self.mediaState = .connecting
        peer.call(peerId: peerId, mediaStream: mediaStream, completion: { [weak self] (result) in

            switch result {
            case .success(_):
                print("call succeeded")

                self?.setupCaptureSession()
                self?.setupLocalMediaStream(mediaStream)
                self?.mediaState = .connected

            case let .failure(error):
                print("call failed: \(error)")
                self?.mediaState = .disconnected
            }
        })
    }

    func answer(connection: PeerConnection) {
        
        print("VideoViewController answer \(connection.connectionType.string)")

        guard let peer = self.peer else {
            return
        }

        if let mediaConnection = connection as? MediaConnection {

            //self.setupCaptureSession()

            let factory = PeerConnectionFactory.sharedInstance
            guard let mediaStream = factory.createLocalMediaStream() else {
                return
            }

            self.mediaState = .connecting
            peer.answer(mediaStream: mediaStream, mediaConnection: mediaConnection, completion: { [weak self] (error) in
                print(error.debugDescription)
                if error == nil {
                    // TODO: check if there are already call view exists
                    self?.setupCaptureSession()
                    self?.setupLocalMediaStream(mediaStream)
                    self?.mediaState = .connected
                }
                else {
                    // TODO: what to do?
                    self?.mediaState = .disconnected
                }
            })
        }
        else if let dataConnection = connection as? DataConnection {

            self.dataState = .connecting
            peer.answer(dataConnection: dataConnection, completion: { [weak self] (error) in
                print(error.debugDescription)
                if error == nil {
                    // TODO: check if there are already call view exists
                    self?.dataState = .connected
                }
                else {
                    // TODO: what to do?
                    self?.dataState = .disconnected
                }
            })
        }
    }

    // MARK: private

    func exitVideoViewIfNeeded() {
        if self.mediaState == .disconnected && self.dataState == .disconnected {
            self.performSegue(withIdentifier: self.backToContactsViewFromVideoSegue, sender: self)
        }
    }

}
