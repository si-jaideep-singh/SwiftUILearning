//
//  ReCAPTCHAViewModel.swift
//  Rajasthan Royals
//
//  Created by Manann Sseth on 20/12/22.
//

import WebKit

protocol ReCaptchaVMDelegate: AnyObject {
    func didSolveCAPTCHA(captchaToken: String)
}

final class ReCaptchaVM: NSObject {
    weak var delegate: ReCaptchaVMDelegate?
    
    var captchaToken: ((String) -> Void)?
    
    var html: String {
        guard let filePath = Bundle.main.path(
            forResource: "recaptcha", ofType: "html"
        ) else {
            assertionFailure("Unable to find the file.")
            return ""
        }
        let contents = try! String(contentsOfFile: filePath, encoding: .utf8)
        return parse(contents, with: ["siteKey": siteKey])
    }
    
    let siteKey: String
    let url: URL
    
    /// Creates a ReCAPTCHAViewModel
    /// - Parameters:
    ///   - siteKey: ReCAPTCHA's site key
    ///   - url: The URL for registered with Google
    init(siteKey: String, url: URL) {
        self.siteKey = siteKey
        self.url = url
        super.init()
    }
}

// MARK: - WKScriptMessageHandler
extension ReCaptchaVM: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let message = message.body as? String else {
            assertionFailure("Expected a string")
            return
        }
        delegate?.didSolveCAPTCHA(captchaToken: message)
        if let token = captchaToken {
            token(message)
        }
    }
}

private extension ReCaptchaVM {
    
    func parse(_ string: String, with valueMap: [String: String]) -> String {
        var parsedString = string
        valueMap.forEach { key, value in
            parsedString = parsedString.replacingOccurrences(
                of: "${\(key)}", with: value
            )
        }
        return parsedString
    }
}
