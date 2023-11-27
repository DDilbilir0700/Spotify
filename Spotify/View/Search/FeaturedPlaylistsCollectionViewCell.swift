//
//  FeaturedPlaylistsCollectionViewCell.swift
//
//  Created by Deniz Dilbilir on 08/12/2023.
//

import UIKit

class FeaturedPlaylistsCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "FeaturedPlaylistsCollectionViewCell"
    
    private let playlistCoverArt = FeaturedPlaylistsCollectionViewCell.createPlaylistCover()
    private let playlistNamelabel = FeaturedPlaylistsCollectionViewCell.createPlaylistNameLabel()
    private let creatorNameLabel = FeaturedPlaylistsCollectionViewCell.createCreatorNameLabel()


    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createPlaylistCover() -> UIImageView {
        let imageView = UIImageView()
      
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private static func createPlaylistNameLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }
    
    private static func createCreatorNameLabel() -> UILabel { // it shows spotify all the time, so i made the color same as background color, if u wanna change it u come here and change it by making color visible.
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .regular)
        let myColor = UIColor(hex: "#121212")
        label.textColor = myColor
        return label
    }
    
    private func setupCell() {
       
        contentView.addSubview(playlistNamelabel)
        contentView.addSubview(playlistCoverArt)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
    }

    override func layoutSubviews() {
         super.layoutSubviews()
        layoutCellElements()
    }
    
    private func layoutCellElements() {
       let imageSize = contentView.height-70
    
        playlistCoverArt.frame = CGRect(x: (contentView.width-imageSize)/2, y: 3, width: imageSize, height: imageSize)
        

        
        playlistNamelabel.frame = CGRect(x: 3, y: contentView.height-60, width: contentView.width-6, height: 30)
        
        
        creatorNameLabel.frame = CGRect(x: 3, y: contentView.height-30, width: contentView.width-6, height: 30)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellContent()
    }
    
    private func resetCellContent() {
        playlistNamelabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverArt.image = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellVM) {
        playlistNamelabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverArt.sd_setImage(with: viewModel.playlistCoverUrl, completed: nil)
    }
}


