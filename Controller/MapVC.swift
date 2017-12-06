import UIKit
import MapKit

class MapVC: UIViewController {
    
    // MARK: - Properties
    //var artworks: [Artwork] = []
    @IBOutlet var mapView: MKMapView!

    let locManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get actual location if user allowed the location permissions.
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            var currentLocation: CLLocation!
            currentLocation = locManager.location
            mapView.showsUserLocation = true
            
            //let location = CLLocationCoordinate2D(latitude: 37.7908432, longitude: -122.4012826)
            //print("Current Location: ",  location)
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)

        } else {
            locManager.requestAlwaysAuthorization()
        }
    }
    
    func loadRestaurants (restaurants: [[String:AnyObject]]) {
        for restaurant in restaurants {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(restaurant["address"] as! String, completionHandler: { (placemarks, error) -> Void in
                if error == nil {
                    if placemarks!.count > 0 {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = (placemarks![0].location?.coordinate)!
                        annotation.title = restaurant["name"] as? String
                        annotation.subtitle = restaurant["rating"] as? String
                        self.mapView.addAnnotation(annotation)
                        
                    }
                }
            })
        }
    }
    
}




