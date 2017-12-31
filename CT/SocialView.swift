//
//  SocialView.swift
//  CT
//
//  Created by John Nik on 4/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

protocol SocialViewDelegate {
    func didClickEmoticon(index: Int)
}

class SocialView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var socialViewDelegate: SocialViewDelegate?
    
    let cellId = "cellId"
    
    let emoticonNames = [AssetName.emoticonLike.rawValue, AssetName.emoticonLove.rawValue, AssetName.emoticonHappy.rawValue, AssetName.emoticonConfused.rawValue, AssetName.emoticonSad.rawValue, AssetName.emoticonAngry.rawValue]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoticonNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SocialButtonCell
        cell.emojiImageView.image = UIImage(named: emoticonNames[indexPath.item])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width / 6, height: frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("social button clicked-", indexPath.item)
        
        self.socialViewDelegate?.didClickEmoticon(index: indexPath.item)
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        
        collectionView.register(SocialButtonCell.self, forCellWithReuseIdentifier: cellId)
    
        addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class SocialButtonCell: UICollectionViewCell {
    
    lazy var emojiButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.emoticonLove.rawValue)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let emojiImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: AssetName.emoticonLove.rawValue)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    private func setupViews() {
        
        addSubview(emojiImageView)
        
        emojiImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        emojiImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
        emojiImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emojiImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


















