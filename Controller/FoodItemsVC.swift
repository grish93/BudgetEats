//
//  FoodItemsVC.swift
//  BudgetEats
//
//  Created by Grishma Athavale on 11/18/17.
//  Copyright © 2017 Grishma Athavale. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration


class FoodItemsVC: UIViewController {
    
    //Search Field
    
    @IBOutlet var searchField: UISearchBar!
    
    var lastSearchQuery: String = "sushi"
    var searchQd: DispatchQueue!
    
    
    
    //Location Identifier
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
        
        //adding search functionality
        // searchField.addTarget(self, action: #selector(FoodItemsTVC.textFieldDidChange(textField:)), for: .editingDidEndOnExit)
    }
    
    // MARK: Networking
    func getRestaurants(_ input: String, _ priceLimit: Int) {
        
        lastSearchQuery = input //we got a new query thats the last thing we are searching for
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
                                    if restaurant["price_range"] as! Int > priceLimit {
                                        continue
                                    }
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
                           // self.tableView.reloadData()
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
    

    @IBOutlet var PriceSeg: UISegmentedControl!
    
    @IBAction func FindBtn(_ sender: Any) {
        // Don't do anything if there is no text
        if(searchField.text == nil || searchField.text == "") {
            return
        }
        let price = PriceSeg.selectedSegmentIndex + 1 as Int
        getRestaurants((searchField.text)!, price)
    }
    
//   PriceFilterSeg {
//
//    }
}


