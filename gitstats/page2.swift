//
//  page2.swift
//  gitstats
//
//  Created by Kempski, Michal on 18/06/2019.
//  Copyright © 2019 Kempski, Michal. All rights reserved.
//

import UIKit

class page2: UIViewController {

    lazy var data = gitResponse()
    
    @IBOutlet weak var usericon: UIImageView!
    @IBOutlet weak var userdata: UILabel!
    @IBOutlet weak var mail: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var stats: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = data.user!
        usericon.load(url: user.avatar_url!)
        userdata?.text = user.login
        bio.text = user.bio
        mail.text = user.email
        self.bio.sizeToFit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        usericon.isUserInteractionEnabled = true
        usericon.addGestureRecognizer(tapGestureRecognizer)
        
        var stat = ""
        for repo in data.repos ?? [repoDTO]() {
            var repoName = repo.name ?? ""
            var repoDesc = repo.description ?? ""
            var repoLang = repo.language ?? ""
            repoName += "                 "
            repoDesc += "                 "
            repoLang += "                 "
            
            let n = "Repository Name: "
            let d = "Repository Description: "
            let l = "Repository Language: "
            
//            stat = stat + "Repository Name: " + repoName + "Repository Description: " + repoDesc + "Repository Language: " +  repoLang

            stat = stat + n + repoName + d + repoDesc + l + repoLang
        }
        self.stats.text = stat
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        UIApplication.shared.openURL(URL(string: data.user!.html_url!)!)
    }
    
}

extension UIImageView {
    func load(url: String) {
        let imageURL = URL(string: url)
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: imageURL!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
