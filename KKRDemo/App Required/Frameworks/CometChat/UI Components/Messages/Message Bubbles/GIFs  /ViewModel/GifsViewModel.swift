//
//  GifsViewModel.swift
//  KKR App
//
//  Created by Vishal Thakur on 11/09/23.
//

import Foundation
import CometChatPro

class GifsViewModel {
    
    var gifyData = [GifyData]()
    private var offset : Int = 1
    private var limit = 30 //50
    var isSearch : Bool = false
    
    func fetchGifs(onSuccess: @escaping() -> Void,
                   onFailure: @escaping(CometChatException) -> Void){
        self.isSearch = false
        CometChat.callExtension(slug: "gifs-giphy", type: .get, endPoint: "v1/trending?offset=\(self.offset)&limit=\(self.limit)", body: nil, onSuccess: { (response) in
            
            if let response = response {
                if self.offset == 1 {
                    self.gifyData.removeAll()
                }
                let model = self.decodeDictToModel(response: response)
                self.gifyData.append(contentsOf: model?.data ?? [])
            }
            onSuccess()
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    onFailure(error)
                }
            }
        }
    }
    

    func searchGifs(searchGifs : String,onSuccess: @escaping() -> Void,
                    onFailure: @escaping(CometChatException) -> Void){
        self.isSearch = true
        CometChat.callExtension(slug: "gifs-giphy", type: .get, endPoint: "v1/search?offset=\(self.offset)&limit=\(self.limit)&query=\(searchGifs)", body: nil, onSuccess: { (response) in
            if let response = response {
                if self.offset == 1 {
                    self.gifyData.removeAll()
                }
                let model = self.decodeDictToModel(response: response)
                self.gifyData.append(contentsOf: model?.data ?? [])
            }
            onSuccess()
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    onFailure(error)
                }
            }
        }
            }
    
    
    func decodeDictToModel(response:[String: Any]) -> GifsData? {
        
        guard let  json = try? JSONSerialization.data(withJSONObject: response)else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(GifsData.self, from: json)
            return data
        } catch {
            return nil
        }
    }
    
    public func updateOffset() {
        self.offset = self.offset + self.limit
    }
    
    public func resetOffset() {
        self.offset = 1
    }
}
