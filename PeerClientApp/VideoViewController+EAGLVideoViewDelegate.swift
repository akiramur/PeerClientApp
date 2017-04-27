//
//  VideoViewController+EAGLVideoViewDelegate.swift
//  PeerClientApp
//
//  Created by Akira Murao on 2017/04/03.
//  Copyright © 2017 Akira Murao. All rights reserved.
//

import Foundation
import PeerClient

extension VideoViewController: EAGLVideoViewDelegate {

    // MARK: EAGLVideoViewDelegate

    func videoView(videoView: EAGLVideoView!, didChangeVideoSize size: CGSize) {

        if videoView == self.localVideoView {
            self.localVideoSize = size
        }
        else if videoView == self.remoteVideoView {
            self.remoteVideoSize = size
        }
        else {
            //NSParameterAssert(false) // TODO:
        }
        
        self.updateVideoViewLayout()
    }
}
