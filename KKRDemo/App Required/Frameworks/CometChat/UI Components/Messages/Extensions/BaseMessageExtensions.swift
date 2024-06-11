//
//  BaseMessageExtensions.swift
//  KKR App
//
//  Created by Valentine Miranda on 07/09/23.
//

import Foundation
import CometChatPro

extension BaseMessage {
    private var pinKey: String {
        return "pinned"
    }
    
    var isPinned: Bool {
        if let metaData = self.metaData {
            if metaData.contains(where: { (key, _) in
                key == pinKey
            }) {
                return true
            }
        }
        return false
    }
    
    public func addPinMessage() {
        let pinData = [pinKey: true]
        self.metaData?.append(with: pinData)
    }
    
    public func removePinMessage() {
        self.metaData?.removeValue(forKey: pinKey)
    }
}

