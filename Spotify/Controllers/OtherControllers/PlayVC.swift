//
//  PlayVC.swift
//
//  Created by Deniz Dilbilir on 03/01/2024.
//

import UIKit
import SDWebImage

protocol PlayVCDelegate : AnyObject {
    func playPausebuttonTouched()
    func forwardButtonTouched()
    func backwardsButtonTouched()
    func didSlide(_ value: Float) 
}

class PlayVC: UIViewController {
    
    weak var dataSource: PlayDataSource?
    weak var delegate: PlayVCDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
 
        return imageView
        
    }()
    
    private let playControlsView = PlayControlsView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        view.addSubview(imageView)
        view.addSubview(playControlsView)
        playControlsView.delegate = self
        barButtonsConfiguration()
        configure()
    
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        
        playControlsView.frame = CGRect(x: 10, y: imageView.bottom+10, width: view.width-20, height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15)
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        playControlsView.configure(with: PlayControlsVM(title: dataSource?.songName, subtitle: dataSource?.subtitleName))
        
    }
    
   private func barButtonsConfiguration() {
       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
       navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAction))
    }
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func didTapAction() {
        
    }
    func refreshUI() {
        configure()
    }
}
extension PlayVC: PlayControlsViewDelegate {
    func playControlsViewDidTapPlayPauseButton(_ playControlsView: PlayControlsView) {
        delegate?.playPausebuttonTouched()
    }
    
    func playControlsViewDidTapBackwardsButton(_ playControlsView: PlayControlsView) {
        delegate?.backwardsButtonTouched()
    }
    
    func playControlsViewDidTapForwardsButton(_ playControlsView: PlayControlsView) {
        delegate?.forwardButtonTouched()
    }
    
    func playControlsView(_ playControlsView: PlayControlsView, didSlide value: Float) {
        delegate?.didSlide(value)
    }
}
