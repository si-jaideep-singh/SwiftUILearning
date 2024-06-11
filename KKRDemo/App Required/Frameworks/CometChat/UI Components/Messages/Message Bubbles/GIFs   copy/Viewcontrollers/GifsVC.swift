//
//  GifsVC.swift
//  KKR App
//
//  Created by Vishal Thakur on 07/09/23.
//

import UIKit

class GifsVC: RootBaseViewController {

    
    @IBOutlet weak var gifsCollView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
//        hG58Udl5tqozCvozfZNj7NhvwL0hCLi8 
      
    }
    func setupInitialUI(){
        gifsCollView.registerCells(cellIdentifiers:[gifsCollViewCell.cellIdentifier])
//        gifsCollView.delegate = self
        gifsCollView.dataSource = self
    }
}


extension GifsVC:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: gifsCollViewCell.cellIdentifier, for: indexPath) as? gifsCollViewCell else {return UICollectionViewCell()
            
        }
        return cell
    }
    
    
}
