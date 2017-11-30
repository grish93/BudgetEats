//
//  FoodItemsTVC.swift
//  BudgetEats
//
//  Created by Grishma Athavale on 11/18/17.
//  Copyright © 2017 Grishma Athavale. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration


class FoodItemsTVC: UITableViewController {

    var locManager: CLLocationManager!
    var restaurants :[[String:AnyObject]] = []
    var searchQueue: DispatchQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isConnectedToNetwork() {
            let alert = UIAlertController(title: "Network Issue", message: "No internet connection!", preferredStyle: .actionSheet)
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        self.locManager = CLLocationManager()
        self.locManager.requestWhenInUseAuthorization()
        self.searchQueue = DispatchQueue(label: "show this")

        self.getRestaurants("sushi")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: Networking
    func getRestaurants(_ input: String) {
        // Setup the URL Request...
        let APIServer: String = "https://developers.zomato.com/api/v2.1/search?q="
        let APIKey: String = "54b1c579e30f377a96a8b2eefc03db30"
        
        var latitude = "34.0522342"
        var longitude = "-118.2436849"
        let radius = "10000" // In meters, so this is 10km.

        // Get actual location if user allowed the location permissions.
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            var currentLocation: CLLocation!
            currentLocation = locManager.location

            if currentLocation != nil {
                latitude = "\(currentLocation.coordinate.latitude)"
                longitude = "\(currentLocation.coordinate.longitude)"
            }
            
        }
        let urlString: String = APIServer + input + "&lat=" + latitude + "&lon=" + longitude + "&radius=" + radius + "&sort=cost&order=desc"
        print(urlString)
        
        let requestUrl = URL(string:urlString)
        var request = URLRequest(url:requestUrl!)
        request.setValue(APIKey, forHTTPHeaderField: "user-key")
        
        // Setup the URL Session...
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // Process the Response...
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode
            print("Status Code for HTTP Response is: \(String(describing: statusCode)) \n")
            print(NSString(data: data!, encoding:String.Encoding.utf8.rawValue)!)

            
            if error == nil, let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                
                // Serialize the JSON Data
                do {
                    let item = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    // Casting serialized data as Dict
                    self.searchQueue.async(group: nil, qos: .default, flags: .barrier, execute: {
                        self.restaurants = []
                        if let dictionary = item as? [String: AnyObject] {
                            print(dictionary)
                            if let rawRestaurants = dictionary["restaurants"] as? [[String:Any]] {
                                print (rawRestaurants)
                                for rawRestaurantData in rawRestaurants {
                                    let rawRestaurant = rawRestaurantData["restaurant"] as? [String:Any]
                                    var restaurant = [String:Any]()
                                    restaurant["name"] = rawRestaurant?["name"]
                                    restaurant["price_range"] = rawRestaurant?["price_range"]
                                    if let userRating = rawRestaurant!["user_rating"] as? [String:Any] {
                                        restaurant["rating"] = userRating["aggregate_rating"]
                                    }
                                    restaurant["thumbnail_url"] = rawRestaurant?["thumb"]
                                    restaurant["menu_url"] = rawRestaurant?["menu_url"]
                                    self.restaurants.append(restaurant as [String : AnyObject])
                                }
                            }
                        }
                        DispatchQueue.main.async() {
                            self.tableView.reloadData()
                        }
                    })

                    // Else take care of JSON Serializing error
                } catch {
                    // Handle Error and Alert User
                    print("Error deserializing JSON: \(error)")
                }
                // Else take care of Networking error
            } else {
                print("Networking Error:\(String(describing: error) )")
            }
        }
        // Execute the URL Task
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantTableViewCell
        
        // making sure that index is in range
        if indexPath.row >= self.restaurants.count {
            return cell!
        }
        searchQueue.sync {
            let restaurant = self.restaurants[indexPath.row]
        
            print(restaurant)
            if restaurant["name"] != nil{
                cell?.myTitle?.text = restaurant["name"] as? String
            }
//            if restaurant["thumbnail_url"] != nil {
//                cell?.myImage?.image = from(link: restaurant["thumbnail_url"] as! String)
//            }
        }
        return cell!
    }
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
