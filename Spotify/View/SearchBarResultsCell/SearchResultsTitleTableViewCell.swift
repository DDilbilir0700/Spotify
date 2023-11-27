//
//  SearchResultsTitleTableViewCell.swift
//
//  Created by Deniz Dilbilir on 02/01/2024.
//


import UIKit
import SDWebImage

class SearchResultsTitleTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "SearchResultsTitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#b3b3b3")
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureFrames()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func configure(with viewModel: SearchResultsTitleTableViewCellVM) {
        label.text = viewModel.title
        titleLabel.text = viewModel.subtitle
        label.textColor = .white
        backgroundColor = UIColor(hex: "#121212")
        iconImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(systemName: "music.note.list"), completed: nil)
    }
    
    private func setupSubviews() {
        contentView.addSubview(label)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    private func configureFrames() {
        let imageSize: CGFloat = contentView.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        
        let labelHeight = contentView.height / 2
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.right - 15, height: labelHeight)
        titleLabel.frame = CGRect(x: iconImageView.right + 10, y: label.bottom, width: contentView.width - iconImageView.right - 15, height: labelHeight)
    }
    
    private func resetCell() {
        iconImageView.image = nil
        label.text = nil
        titleLabel.text = nil
    }
}
