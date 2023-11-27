//
//  AlertLabelView.swift
//
//  Created by Deniz Dilbilir on 12/01/2024.
//

import UIKit

struct AlertLabelVM {
    let text: String
    let alertTitle: String
}

protocol AlertLabelViewDelegate: AnyObject {
    func alertLabelViewButtonTouched(_ alertView: AlertLabelView)
}

class AlertLabelView: UIView {
    
    weak var delegate: AlertLabelViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        isHidden = true
        button.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTouched() {
        delegate?.alertLabelViewButtonTouched(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height - 40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height - 45)
    }
    
    func configure(with viewModel: AlertLabelVM) {
        label.text = viewModel.text
        button.setTitle(viewModel.alertTitle, for: .normal)
    }
    
    private func setupSubviews() {
        addSubview(label)
        addSubview(button)
        clipsToBounds = true
    }
}
