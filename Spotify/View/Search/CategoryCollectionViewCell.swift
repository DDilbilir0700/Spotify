//
//  GenresCollectionViewCell.swift
//
//  Created by Deniz Dilbilir on 25/12/2023.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "CategoryCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let colors: [UIColor] = [
        .systemRed,
        .systemOrange,
        .systemYellow,
        .systemTeal,
        .systemPink,
        .systemGreen,
        .systemBlue,
        .systemCyan,
        .systemBrown,
        .systemIndigo,
        .systemPurple,
        .systemIndigo,
        .darkGray
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCellElements()
    }
    
    func configuration(with viewModel: CategoryCollectionViewCellVM) {
        label.text = viewModel.categoryName
        imageView.sd_setImage(with: viewModel.categoryCoverUrl, completed: nil)
        contentView.backgroundColor = colors.randomElement()
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    private func resetCellContent() {
        label.text = nil
        imageView.image = UIImage(systemName: "music.note", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    
    private func layoutCellElements() {
        label.frame = CGRect(x: 10, y: contentView.height / 2, width: contentView.width - 20, height: contentView.height / 2)
        
        let imageSize = contentView.height / 1.3
        imageView.frame = CGRect(x: contentView.width - imageSize + 20, y: contentView.height - imageSize, width: imageSize, height: imageSize)
        
        let rotationAngle = 20 * CGFloat.pi / 180
        imageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
}

