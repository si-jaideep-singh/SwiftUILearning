//
//  gifsCollViewCell.swift
//  KKR App
//
//  Created by Vishal Thakur on 07/09/23.
//

import UIKit
import CometChatPro
import SDWebImage

class GifsCollViewCell: RootBaseCollectionViewCell {
    
    
    @IBOutlet weak var gifsImgView: SDAnimatedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifsImgView.image = nil
    }
  
    func setupCellData(data: GifyData?){
        guard let data = data else { return }
        guard let url = URL(string: data.images?.previewGIF?.url ?? "") else{ return}
        DispatchQueue.main.async {
            self.gifsImgView.sd_setImage(with: url)
        }
        
    }
}
