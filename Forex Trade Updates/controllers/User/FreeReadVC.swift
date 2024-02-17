//
//  FreeReadVC.swift
//  Forex Trade Updates
//
//  Created by Arslan Khalid on 22/08/2023.
//  Copyright © 2023 Arslan. All rights reserved.
//

import UIKit


class ReadingCell: UICollectionViewCell {
    
    @IBOutlet weak var bgimage: UIImageView!
    
    @IBOutlet weak var readingTitle: UILabel!
    @IBOutlet weak var readingDesc: UILabel!
    
    var cellIndex: Int = 0 {
        didSet {
            bgimage.image = UIImage(named: "\(cellIndex)")
            switch cellIndex {
//            case 0 :
//                readingTitle.text = "Swipe to see different sections"
//                readingDesc.text = ""
            case 0 :
                readingTitle.text = "What is Pip?"
                readingDesc.text = "The smallest whole unit measurement of the difference between ..."
            case 1 :
                readingTitle.text = "How to Take A Signal?"
                readingDesc.text = "Signals are ascertained after analysing the currency pair's historical price movements ..."
                //bgimage.image = UIImage(named: "kbbbblogoooo")
            case 2 :
                
                readingTitle.text = "How to Secure Profits?"
                readingDesc.text = "Understand your exposures, Create a strategy ..."
            default:
                break
            }
            
        }
    }
    
    override func prepareForReuse() {
        bgimage.image = nil
    }
    
}




class FreeReadVC: UIViewController, UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset.x, scrollView.frame.width)
        let value = scrollView.contentOffset.x / scrollView.frame.width
        let newval = Int(value.rounded())
        pagecontrol.currentPage = newval
    }
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var pagecontrol: UIPageControl!
    //var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.delegate = self
        collectionview.isPagingEnabled = true
        collectionview.dataSource = self
        collectionview.showsHorizontalScrollIndicator = false
        //pagecontrol.currentPage = 0
        setupCollectionViewLayout()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    fileprivate func setupCollectionViewLayout() {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: (self.view.frame.width) - 48, height: 400)
//        layout.scrollDirection = .horizontal
//        collectionview.collectionViewLayout = layout
    }
}


extension FreeReadVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width - 20, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReadingCell.className, for: indexPath) as! ReadingCell
        cell.cellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var fileName: String = ""
        if indexPath.row == 0 {
            fileName = "What is a Pip"
        }
        
        if indexPath.row == 1 {
            fileName = "How To Take A Signal"
        }
        
        if indexPath.row == 2 {
            fileName = "How to Secure Profits"
        }
        if let vc = storyboard?.instantiateViewController(withIdentifier: LoadPDFVC.className) as? LoadPDFVC {
            vc.fileName = fileName
            vc.pagetitle = fileName
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
