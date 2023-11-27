//
//  PlayControlsView.swift
//
//  Created by Deniz Dilbilir on 04/01/2024.
//

import Foundation
import UIKit

import Foundation
import UIKit

protocol PlayControlsViewDelegate: AnyObject {
    func playControlsViewDidTapPlayPauseButton(_ playControlsView: PlayControlsView)
    func playControlsViewDidTapBackwardsButton(_ playControlsView: PlayControlsView)
    func playControlsViewDidTapForwardsButton(_ playControlsView: PlayControlsView)
    func playControlsView(_ playControlsView: PlayControlsView, didSlide value: Float)
}

struct PlayControlsVM {
    let title: String?
    let subtitle: String?
}

final class PlayControlsView: UIView {
    
    private var isPlaying = true
    
    weak var delegate: PlayControlsViewDelegate?
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Blood On The Leaves"
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let playlistOrAlbumLabel: UILabel = {
        let label = UILabel()
        label.text = "Kanye West"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        let myColor = UIColor(hex: "#b3b3b3")
        label.textColor = myColor
        return label
    }()
    
    private let backwardsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .ultraLight))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let forwardsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .ultraLight))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "pause.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 90, weight: .bold))
        button.setImage(image, for: .normal)
       
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let myColor = UIColor(hex: "#121212")
        backgroundColor = myColor
        addSubview(volumeSlider)
        addSubview(songNameLabel)
        addSubview(playlistOrAlbumLabel)
        addSubview(backwardsButton)
        addSubview(forwardsButton)
        addSubview(playPauseButton)
        volumeSlider.addTarget(self, action: #selector(didSlide(_:)), for: .valueChanged)
        
        backwardsButton.addTarget(self, action: #selector(didTapBackwardsButton), for: .touchUpInside)
        forwardsButton.addTarget(self, action: #selector(didTapForwardsButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didSlide(_ slider: UISlider) {
        let value = slider.value
        delegate?.playControlsView(self, didSlide: value)
    }
    
    @objc private func didTapBackwardsButton() {
        delegate?.playControlsViewDidTapBackwardsButton(self)
    }
    
    @objc private func didTapForwardsButton() {
        delegate?.playControlsViewDidTapForwardsButton(self)
    }
    
    @objc private func didTapPlayPauseButton() {
        self.isPlaying = !isPlaying
        delegate?.playControlsViewDidTapPlayPauseButton(self)
        let pause = UIImage(systemName: "pause.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 90, weight: .bold))
        let play = UIImage(systemName: "play.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 90, weight: .bold))
        playPauseButton.setImage(isPlaying ? pause: play, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        songNameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        playlistOrAlbumLabel.frame = CGRect(x: 0, y: songNameLabel.bottom+10, width: width, height: 50)
        volumeSlider.frame = CGRect(x: 10, y: playlistOrAlbumLabel.bottom+20, width: width-20, height: 44)
        let buttonSize: CGFloat = 100
        playPauseButton.contentMode = .center
        playPauseButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        playPauseButton.frame = CGRect(x: (width - buttonSize)/2, y: volumeSlider.bottom + 30, width: buttonSize, height: buttonSize)
        backwardsButton.frame = CGRect(x: playPauseButton.left-15-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        forwardsButton.frame = CGRect(x: playPauseButton.right+15, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }
    
    func configure(with viewModel: PlayControlsVM) {
        songNameLabel.text = viewModel.title
        playlistOrAlbumLabel.text = viewModel.subtitle
    }
}
