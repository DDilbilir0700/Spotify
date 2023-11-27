//
//  PlaylistCollectionReusableView.swift
//
//  Created by Deniz Dilbilir on 18/12/2023.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func PlaylistHeaderCollectionReusableViewDidTapPlay(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
  
    static let cellIdentifier = "PlaylistCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#121212")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let myColor = UIColor(hex: "#b3b3b3")
        label.textColor = myColor
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        let myButtonColor = UIColor(hex: "#1db954")
        button.backgroundColor = myButtonColor
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tappedPlayButton() {
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlay(self)
    }
    
    private func setupSubviews() {
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(ownerLabel)
        addSubview(descriptionLabel)
        addSubview(playButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = height / 2
        imageView.frame = CGRect(x: (width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)

        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width - 20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width - 20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: ownerLabel.bottom - 10, width: width - 20, height: 44)
        playButton.frame = CGRect(x: width - 100, y: height - 45, width: 40, height: 40)
    }

    func configure(with viewModel: PlaylistHeaderVM) {
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.owner
        descriptionLabel.text = viewModel.description
        imageView.sd_setImage(with: viewModel.artWork, placeholderImage: UIImage(systemName: "music.note"), completed: nil)
    }
}
