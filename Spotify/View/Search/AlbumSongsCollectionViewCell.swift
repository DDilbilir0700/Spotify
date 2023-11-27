//
//  AlbumSongsCollectionViewCell.swift
//
//  Created by Deniz Dilbilir on 21/12/2023.
//

import UIKit

class AlbumSongsCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "AlbumSongsCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        let myColor = UIColor(hex: "#121212")
        contentView.backgroundColor = myColor
        contentView.addSubview(trackNameLabel)
        contentView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCellElements()
    }
    
    private func layoutCellElements() {
        trackNameLabel.frame = CGRect(x: 10, y: 0, width: contentView.width - 15, height: contentView.height / 2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellContent()
    }
    
    private func resetCellContent() {
        trackNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumCollectionViewCellVM) {
        trackNameLabel.text = viewModel.trackName
    }
}

    



