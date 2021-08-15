//
//  ViewController.swift
//  Reqres App
//
//  Created by Girish Parate on 15/08/21.
//

import UIKit

class ViewController: UIViewController {
    
    static let sharedWebClient = WebClient.init(baseUrl: "https://reqres.in/api")
    
    @IBOutlet var tableview: UITableView!
    
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friends: [UserItem] = [] {
        didSet {
            updateUI()
        }
    }
    
    var friendsTask: URLSessionDataTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.tableFooterView = UIView(frame: .zero)
        loadFriends()
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func moveToLogin() {
        
    }
    
    private func handleError(_ error: WebError<CustomError>) {
        switch error {
        case .noInternetConnection:
            showErrorAlert(with: "The internet connection is lost")
        case .unauthorized:
            moveToLogin()
        case .other:
            showErrorAlert(with: "Unfortunately something went wrong")
        case .custom(let error):
            showErrorAlert(with: error.message)
        }
    }
    
    @IBAction private func loadFriends() {
        friendsTask?.cancel()
        
//        activityIndicator.startAnimating()
        let exampleDict: [String: Any] = [
                "per_page" : 20,         // type: String
            ]
        
        let parmas = UserRepo().getUserRepo(params: exampleDict)
        
        friendsTask = ViewController.sharedWebClient.load(resource: parmas) {[weak self] response in
            
            guard let controller = self else { return }
            
            DispatchQueue.main.async {
//                controller.activityIndicator.stopAnimating()
                
                if let friends = response.value?.data {
                    controller.friends = friends
                } else if let error = response.error {
                    controller.handleError(error)
                }
            }
        }
    }
    
    private func updateUI() {
        tableview.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.first_name
        cell.detailTextLabel?.text = friend.email
        return cell
    }
}


