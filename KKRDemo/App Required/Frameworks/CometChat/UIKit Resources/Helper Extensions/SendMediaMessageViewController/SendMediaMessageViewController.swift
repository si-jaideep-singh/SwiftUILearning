//
//  SendMediaMessageViewController.swift
//  CometChatSwift
//
//  Created by admin on 15/08/23.
//  Copyright © 2023 MacMini-03. All rights reserved.
//

import UIKit
import ImageIO

class SendMediaMessageViewController: UIViewController {

    @IBOutlet weak var sendingMessageView: UIImageView!
    var onSendMessageTapped: (()->Void)?
    
    var imageData: UIImage?
    var dataGIF: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendingMessageView.image = imageData
        if let dataGIF = dataGIF {
            sendingMessageView.loadGif(fromData: dataGIF)
        }
        
        // Do any additional setup after loading the view.
    }
    
    func setData(image: UIImage?, data: Data?){
        imageData = image
        dataGIF = data
//        sendingMessageView.image = imagekk
        
    }
    
    @IBAction func onSendButtonCalled(_ sender: Any) {
        onSendMessageTapped?()
        self.dismiss(animated: true)
    }
    
    @IBAction func onCancleButtonCalled(_ sender: Any) {
        self.dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



