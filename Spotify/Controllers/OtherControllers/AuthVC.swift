//
//  AuthVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit
import WebKit

class AuthVC: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView?
    
    var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        setUpWebView()
        webView?.navigationDelegate = self
        if let webView = webView {
            view.addSubview(webView)
        } else {
            print("webView is nil.")
        }
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        webView?.load(URLRequest(url: url))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView?.frame = view.bounds
    }
    
    private func setUpWebView() {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        webView = WKWebView(frame: .zero, configuration: configuration)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            print("No URL in web view")
            return
        }
        
        print("Web view started loading: \(url)")
        if url.absoluteString.starts(with: "https://ddenizdilbilir.wordpress.com/") {
            guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
                print("Could not find 'code' in URL")
                return
            }

            AuthManager.shared.exchangeForToken(code: code) { [weak self] success in
                DispatchQueue.main.async {
                    print("Token exchange callback: \(success)")
                    if success {
                        self?.handleSignInSuccess()
                    } else {
                        self?.handleSignInFailure()
                    }
                }
            }
        }
    }

    private func handleSignInSuccess() {
        let tabBarVC = TabBarVC()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true, completion: nil)
    }

    private func handleSignInFailure() {
        let alert = UIAlertController(
            title: "Sign In Failed",
            message: "There was an issue signing you in. Please try again.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
