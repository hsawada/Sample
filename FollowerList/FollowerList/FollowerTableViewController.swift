//
//  FollowerTableViewController.swift
//  FollowerList
//
//  Created by hsawada on 2017/08/15.
//  Copyright © 2017 hsawada. All rights reserved.
//

import UIKit

// TODO: iOS 11 no longer supports using Twitter through Social framework.
// For more details, https://dev.twitter.com/twitterkit/ios/migrate-social-framework
import Accounts
import Social

class FollowerTableViewController: UITableViewController {

    // MARK: - Properties
    
    var accountStore = ACAccountStore()
    var twitterAccount: ACAccount?
    var users = [Any]()

    // MARK: - Twitter Helpers
    
    private func startGettingFollowers()
    {
        // Get Twitter account at first
        
        let accountType = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        self.accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted, error) in
            if error != nil {
                print("Failed to access accounts")
                // TODO: Friendly alert message
                return
            }
            if !granted {
                print("Failed to access Twitter accounts")
                // TODO: Navigate to Settings
                return
            }
            
            let accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
            if accounts.count == 0 {
                print("Need to setup Twitter account")
                // TODO: Fall back to web-based OAuth
                return
            }
            
            // TODO: Support multiple accounts
            self.twitterAccount = accounts[0]
            self.getFollowers()
        }
    }
    
    private func getFollowers() {
        //let url = URL(string: "https://api.twitter.com/1.1/friends/list.json") // Debug code for many followers case
        let url = URL(string: "https://api.twitter.com/1.1/followers/list.json?skip_status=true&include_user_entities=false")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, url: url, parameters: nil)
        request?.account = self.twitterAccount
        request?.perform(handler: { (data, response, error) in
            if error != nil {
                print("error \(String(describing: error))")
                return
            }
            else if data != nil {
                let results = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                self.users = results?["users"] as! [Any]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    // MARK: - View controller

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startGettingFollowers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath)
        let userProps = self.users[indexPath.item] as! [String: Any]
        cell.textLabel?.text = userProps["name"] as? String
        return cell
    }
}
