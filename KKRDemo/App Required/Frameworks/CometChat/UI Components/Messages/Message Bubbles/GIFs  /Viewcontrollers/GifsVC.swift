//
//  GifsVC.swift
//  KKR App
//
//  Created by Vishal Thakur on 07/09/23.
//

import UIKit
import SDWebImage

protocol GIFsSelectionDelegate {
    func didSelectGIF(with data: GifyData)
}

class GifsVC: RootBaseViewController {

    @IBOutlet weak var gifsCollView: UICollectionView!
    @IBOutlet weak var gifsSearchBar: UISearchBar!
    
    @IBOutlet weak var cancel_btn: UIButton!
    
    lazy var viewModel = GifsViewModel()
    public var delegate: GIFsSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        viewModel.resetOffset()
        fetchGify()
//        hG58Udl5tqozCvozfZNj7NhvwL0hCLi8
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        viewModel.resetOffset()
//        fetchGify()
    }
 
    
    
    @IBAction func cancelBtnClick(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    func setupInitialUI(){
        gifsCollView.registerCells(cellIdentifiers:[GifsCollViewCell.cellIdentifier])
        gifsCollView.delegate = self
        gifsCollView.dataSource = self
        setupSearchBar()
    }
    
    func setupSearchBar(){
        gifsSearchBar.delegate = self
        gifsSearchBar.showsCancelButton = false
        gifsSearchBar.setImage(UIImage(named:"search_icon"), for: .search, state: .normal)
    }
    
    
    func fetchGify(){
//        showActivityHud()
        viewModel.fetchGifs() {
            DispatchQueue.main.async {
                self.gifsCollView.reloadData()
                self.hideActivityHud()
            }
        } onFailure: { error in
            KKRToastView.showToast(withMessage: error.errorDescription)
//            self.hideActivityHud()
        }

    }
    func searchGify(searchGifs:String){
//        showActivityHud()
        viewModel.searchGifs(searchGifs: searchGifs) {
            DispatchQueue.main.async {
                self.gifsCollView.reloadData()
//                self.hideActivityHud()
            }
        } onFailure: { error in
            KKRToastView.showToast(withMessage: error.errorDescription)
//            self.hideActivityHud()
        }

    }
}


extension GifsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.gifyData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GifsCollViewCell.cellIdentifier, for: indexPath) as? GifsCollViewCell else {return UICollectionViewCell()
            
        }
        
        let data = viewModel.gifyData[safe: indexPath.row]
        cell.setupCellData(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.gifyData.count - 11 {
            viewModel.updateOffset()
            if viewModel.isSearch{
                guard let searchText = gifsSearchBar.text else{return}
                searchGify(searchGifs:searchText)
            }
            else{
                fetchGify()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gifyData = viewModel.gifyData[indexPath.row]
        delegate?.didSelectGIF(with: gifyData)
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.bounds.width - 12) / 2
        return CGSize(width: side, height: side)
    }
}

extension GifsVC : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else{return}
//        viewModel.isSearch = true
        self.searchGify(searchGifs: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        viewModel.resetOffset()
        self.fetchGify()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(performSearchQuery),
                                               object: searchBar)
        self.perform(#selector(performSearchQuery),
                     with: searchBar,
                     afterDelay: 0.3)
    }
    
    @objc private func performSearchQuery(searchBar: UISearchBar) {
        guard let searchText = gifsSearchBar.text else { return }
        viewModel.resetOffset()
        if searchText == "" {
            fetchGify()
        }else{
            self.searchGify(searchGifs: searchText)
        }
    }
}
