//
//  SelectNPKIViewController.swift
//  OmniDocSample
//
//  Created by Jinryul.Kim on 2017. 6. 29..
//  Copyright © 2017년 FlyHigh. All rights reserved.
//

import UIKit

protocol SelectNPKIDelegate: class {
    func onSelectNPKI(selected: Int)
}

class SelectNPKIVC : PopupVC, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: SelectNPKIDelegate? = nil
    public var arrNPKI = Array<String>()
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        self.title = "공인인증서 선택"
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arrNPKI =  self.object["list"] as! [String]
        self.collectionView.reloadData()
    }
    
    @IBAction func onTouchUpInsideBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //
    // CollectionView
    //
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrNPKI.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NPKICell = collectionView.dequeueReusableCell(withReuseIdentifier: "NPKICell", for: indexPath) as! NPKICell
    
        let itemsInRow: CGFloat = 1
        let defaultMargin: CGFloat = 4
        let fullWidth = view.frame.width - (2 * defaultMargin)
        let singleItemWidth = (fullWidth - ((itemsInRow - 1) * defaultMargin)) / itemsInRow
        cell.bounds.size.width = singleItemWidth
        
        let npki: String = arrNPKI[indexPath.row]
        
        let fileMgr = FileManager.default
        let documentDir = try! fileMgr.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let npkiDir = documentDir.appendingPathComponent(npki, isDirectory: true)
        
        let signDer = npkiDir.appendingPathComponent("signCert.der")
        let signKey = npkiDir.appendingPathComponent("signPri.key")
        
        if FileManager.default.fileExists(atPath: signDer.path) && FileManager.default.fileExists(atPath: signKey.path) {
            cell.labelName.text = npki
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.onSelectNPKI(selected: indexPath.item)
        dismiss(animated: true, completion: nil)
    }
}
