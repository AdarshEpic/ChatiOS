//
//  File.swift
//  ChatApp
//
//  Created by Focaloid on 18/04/19.
//  Copyright © 2019 Focaloid. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}
