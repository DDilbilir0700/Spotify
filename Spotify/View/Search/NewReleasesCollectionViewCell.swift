//
//  NewReleasesCollectionViewCell.swift
//
//  Created by Deniz Dilbilir on 08/12/2023.
//

import UIKit
import SDWebImage


import UIKit
import SDWebImage

class NewReleasesCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "NewReleasesCollectionViewCell"
    
    private let albumCoverImageView = NewReleasesCollectionViewCell.createImageView()
    private let albumNameLabel = NewReleasesCollectionViewCell.createAlbumNameLabel()
    private let tracksCountLabel = NewReleasesCollectionViewCell.createTracksCountLabel()
    private let artistNameLabel = NewReleasesCollectionViewCell.createArtistNameLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createAlbumNameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }
    
    private static func createTracksCountLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }
    
    private static func createArtistNameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }
    
    private func setupCell() {

        let myColor = UIColor(hex: "#121212")
        contentView.backgroundColor = myColor


        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(tracksCountLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(albumNameLabel)
        contentView.clipsToBounds = true
    }

    override func layoutSubviews() {
         super.layoutSubviews()
        layoutCellElements()
    }
    
    private func layoutCellElements() {
        let imageSize: CGFloat = contentView.height-10
        let albumNameLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-imageSize-10, height: contentView.height-10))
        artistNameLabel.sizeToFit()
        tracksCountLabel.sizeToFit()
      
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        let albumLabelHeight = min(50, albumNameLabelSize.height)
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: 5, width: albumNameLabelSize.width, height: albumLabelHeight)
        
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: albumNameLabel.bottom, width: contentView.width - albumCoverImageView.right-10, height: 20)
        
        tracksCountLabel.frame = CGRect(x: albumCoverImageView.right+10, y: contentView.bottom-45, width: tracksCountLabel.width, height: 45)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellContent()
    }
    
    private func resetCellContent() {
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        tracksCountLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: NewReleasesCellVM) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        tracksCountLabel.text = "Tracks: \(viewModel.totalTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.coverArtURL, completed: nil)
    }
}
