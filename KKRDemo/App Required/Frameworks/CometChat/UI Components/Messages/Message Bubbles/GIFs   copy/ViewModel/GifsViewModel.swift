//
//  GifsViewModel.swift
//  KKR App
//
//  Created by Vishal Thakur on 11/09/23.
//

import Foundation
import CometChatPro

class GifsViewModel{

    
    func fetchGifs(){
        CometChat.callExtension(slug: "gifs-giphy", type: .get, endPoint: "v1/trending?offset=10&limit=15", body: nil, onSuccess: { (response) in
            print(response)              }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
    }
}
