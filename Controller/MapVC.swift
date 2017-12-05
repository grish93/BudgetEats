import UIKit
import MapKit

class MapVC: UIViewController {
    
    // MARK: - Properties
    //var artworks: [Artwork] = []
    @IBOutlet var mapView: MKMapView!

    let locManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locManager.requestAlwaysAuthorization()
        }
        let location = CLLocationCoordinate2D(latitude: 37.7908432, longitude: -122.4012826)
       
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

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
//
// MARK: - MKMapViewDelegate



