//
//  RecommendedTracksCollectionViewCell.swift
//
//  Created by Deniz Dilbilir on 08/12/2023.
//

import UIKit
import SDWebImage
class RecommendedTracksCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTracksCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let trackCoverView : UIImageView =  {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let myColor = UIColor(hex: "#212121")
        contentView.backgroundColor = myColor
        contentView.clipsToBounds = true
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(trackCoverView)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        trackCoverView.image = nil
    }
    override func layoutSubviews() {
        trackNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        trackCoverView.sizeToFit()
        
        trackNameLabel.clipsToBounds = true
        artistNameLabel.clipsToBounds = true
        trackCoverView.clipsToBounds = true
        
        
        trackCoverView.frame = CGRect(x: 0, y: 0, width: contentView.width * 1/6, height: contentView.height)
        trackNameLabel.frame = CGRect(x: trackCoverView.right + 5, y: 0, width: contentView.width - (contentView.width * 1/4) - 10, height: contentView.height / 2)
        artistNameLabel.frame = CGRect(x: trackCoverView.right + 5, y: contentView.height / 2, width: contentView.width - (contentView.width * 1/4) - 10, height: contentView.height / 2)

    }
    func configure(with viewModel: RecommendedTracksCellVM) {
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        trackCoverView.sd_setImage(with: viewModel.coverArtURL)
    }
    
}
