//
//  ViewController.swift
//  CollectionViews
//
//  Created by Yariv Nissim on 5/23/18.
//  Copyright © 2018 Yariv Nissim. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            collectionView.flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }

    private var categories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        updateItemSize(for: view.frame.size)

        Tradesy.getItemsByCategory { categories in
            self.categories = categories
            self.collectionView.reloadData()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateItemSize(for: size)
    }

    private func updateItemSize(for size: CGSize) {
        let count: CGFloat

        if size.width >= size.height {
            count = 4
        } else {
            count = 2
        }

        let flowLayout = collectionView.flowLayout!
        let itemSpacing = flowLayout.minimumInteritemSpacing * (count-1)
        let width = size.width

        let size = width/count - itemSpacing
        let newInsets = (width-size*count - itemSpacing)/2

        collectionView.flowLayout.itemSize = CGSize(width: size, height: size)
        collectionView.flowLayout.sectionInset.left = newInsets
        collectionView.flowLayout.sectionInset.right = newInsets
        //collectionView.flowLayout.invalidateLayout()
        //collectionView.layoutIfNeeded()
    }
}

extension ItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
}

extension ItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ItemCell else { return }
        let item = categories[indexPath]
        cell.titleLabel.text = item.title
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == UICollectionElementKindSectionHeader, let header = view as? CategoryHeader else { return }

        header.titleLabel.text = categories[indexPath.section].name
    }
}

class ItemCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        layer.cornerRadius = 13
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.cgColor

        prepareForReuse()
    }

    override func prepareForReuse() {
        titleLabel.text = nil
    }
}

class CategoryHeader: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
}

extension UICollectionView {
    var flowLayout: UICollectionViewFlowLayout! {
        return collectionViewLayout as? UICollectionViewFlowLayout
    }
}
