//
//  ImageViewExtension.swift
//  AcronymsIOS
//
//  Created by Zarina Bekova on 5/25/21.
//

import UIKit

extension UIImageView {
    
    func loadImage(router: Router) {
        
        guard let url = router.url else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method.rawValue
        urlRequest.allHTTPHeaderFields = router.header
        
        URLSession.shared.downloadTask(with: urlRequest) { [weak self] (url, response, error) in
            if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        } .resume()
    }
}
