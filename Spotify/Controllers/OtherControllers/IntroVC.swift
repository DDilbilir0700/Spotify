//
//  IntroVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

class IntroVC: UIViewController {
    
    private let signInButton = UIButton()
      
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums")
        return imageView
        
    }()
    
    private let uiView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    private let logoImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "spotify"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Millions of songs.\nFree on Spotify."
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Spotify"
        view.addSubview(imageView)
        view.addSubview(uiView)
        let myColor = UIColor(hex: "##1db954")
        view.backgroundColor = myColor
       
        configureSignInButton()
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        view.addSubview(label)
        view.addSubview(logoImageView)
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        uiView.frame = view.bounds
        signInButton.frame = CGRect(x: 20, y: view.height-100-view.safeAreaInsets.bottom, width: view.width-40, height: 50)
        logoImageView.frame = CGRect(x: (view.width-120)/2, y: (view.height-350)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom+30, width: view.width-60, height: 150)
    }
    
    func configureSignInButton() {
   
        signInButton.backgroundColor = .systemGreen
               signInButton.setTitle("Sign In ", for: .normal)
               view.addSubview(signInButton)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
               signInButton.setTitleColor(.black, for: .normal)
        
    
           signInButton.layer.cornerRadius = 25
           signInButton.layer.masksToBounds = true
       
    }
   
    @objc func didTapSignIn() {
        let vc = AuthVC()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.signInHandler(success: success)
            }
            
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    private func signInHandler(success: Bool) {
        print("Sign in handler called with success: \(success)")
        guard success else {
            let alert = UIAlertController(
                title: "Oops!🫣",
                message: "Sorry, we encountered an issue while signing you in. Please double-check your credentials and try again. If the problem persists, contact support for assistance.",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)

            return
        }
        let tabBarVC = TabBarVC()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
}
