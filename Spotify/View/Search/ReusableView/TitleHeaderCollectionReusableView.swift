//
//  TitleHeaderCollectionReusableView.swift
//
//  Created by Deniz Dilbilir on 20/12/2023.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let cellIdentifier = "TitleHeaderCollectionReusableView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let myColor = UIColor(hex: "#121212")
        backgroundColor = myColor
        addSubview(label)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    
    func configure(with title: String) {
        label.text = title
    }
}
