//
//  ViewController.swift
//  gitstats
//
//  Created by Kempski, Michal on 24/05/2019.
//  Copyright © 2019 Kempski, Michal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyRoundCorners(btnLogin)
    }
    
    @IBAction func onButtonClick(_ sender: Any) {
        let reposURL = URL(string: "https://api.github.com/user/repos")!
        let userURL = URL(string: "https://api.github.com/user")!
        var reposRequest = URLRequest(url: reposURL)
        var userRequest = URLRequest(url: userURL)
        reposRequest.httpMethod = "GET"
        userRequest.httpMethod = "GET"

        let auth = loginField.text! + ":" + passwordField.text!
        reposRequest.setValue("Basic " + auth.toBase64(), forHTTPHeaderField: "Authorization")
        reposRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        userRequest.setValue("Basic " + auth.toBase64(), forHTTPHeaderField: "Authorization")
        userRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let p = self.storyboard?.instantiateViewController(withIdentifier: "stats") as! page2

        
        NSURLConnection.sendAsynchronousRequest(reposRequest, queue: OperationQueue.main) {(response, data, error) in
            do {
                if let httpResponse = response as? HTTPURLResponse{
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers);
                    
                    if httpResponse.statusCode == 200{
                        p.data.repos = self.mapRepos(data: jsonResult)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        NSURLConnection.sendAsynchronousRequest(userRequest, queue: OperationQueue.main) {(response, data, error) in
            do {
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{
                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableLeaves);
                       
                        p.data.user = self.mapUser(data: jsonResult)
                        self.present(p, animated: false, completion: nil)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func mapUser(data: Any) -> userDTO {
        guard let jsonArray = data as? [String: Any] else {
            return userDTO()
        }
        let result = jsonArray
        
        return userDTO(login: loginField.text!,
                       name: result["name"] as? String,
                       email: result["email"] as? String,
                       avatar_url: result["avatar_url"] as? String,
                       repos_url: result["repos_url"] as? String,
                       html_url: result["html_url"] as? String,
                       bio: result["bio"] as? String)
    }
    
    func mapRepos(data: Any) -> [repoDTO] {
        var result = [repoDTO]()
        guard let jsonArray = data as? [[String: Any]] else {
            return result
        }
        for key in jsonArray {
            var repo = repoDTO()
            repo.created_at = key["created_at"] as? String
            repo.description = key["description"] as? String
            repo.html_url = key["html_url"] as? String
            repo.name = key["name"] as? String
            repo.language = key["language"] as? String
            repo.languages_url = key["language_url"] as? String
            repo.size = key["size"] as? Int
            result.append(repo)
        }
        
        return result
    }
    
    func goToScreen(id : String) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "page2", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: id)
        self.present(newViewController, animated: false, completion: nil)
    }
    
    func applyRoundCorners(_ object: AnyObject){
        object.layer?.cornerRadius = 20
    }
}

struct userDTO : Decodable{
    var login: String?
    var name: String?
    var email: String?
    var avatar_url: String?
    var repos_url: String?
    var html_url: String?
    var bio: String?
}
struct repoDTO : Decodable {
    var name: String?
    var description: String?
    var html_url: String?
    var languages_url: String?
    var language: String?
    var created_at: String?
    var size: Int?
}
struct gitResponse {
    var user: userDTO?
    var repos: [repoDTO]?
}

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
