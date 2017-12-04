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

//        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
//            centerMapOnLocation(location: locManager.location!)
//        }
        
        //mapView.delegate = self
        //    mapView.register(ArtworkMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //       mapView.register(ArtworkView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //loadInitialData()
        // mapView.addAnnotations(artworks)
        
        // show artwork on map
        //    let artwork = Artwork(title: "King David Kalakaua",
        //      locationName: "Waikiki Gateway Park",
        //      discipline: "Sculpture",
        //      coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        //    mapView.addAnnotation(artwork)
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
                        annotation.subtitle = "Rating: " + (restaurant["rating"] as? String)!
                        self.mapView.addAnnotation(annotation)
                        
                        //                    self.mapView.showAnnotations([annotation], animated: true)
                        //                    self.mapView.selectedAnnotations(annotation, animated: true)
                    }
                }
            })
        }
    }
    
}
//
//// MARK: - MKMapViewDelegate
//
//extension ViewController: MKMapViewDelegate {
//
//    //   1
//    //  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//    //    guard let annotation = annotation as? Artwork else { return nil }
//    //    // 2
//    //    let identifier = "marker"
//    //    var view: MKMarkerAnnotationView
//    //    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//    //      as? MKMarkerAnnotationView { // 3
//    //      dequeuedView.annotation = annotation
//    //      view = dequeuedView
//    //    } else {
//    //      // 4
//    //      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//    //      view.canShowCallout = true
//    //      view.calloutOffset = CGPoint(x: -5, y: 5)
//    //      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//    //    }
//    //    return view
//    //  }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                 calloutAccessoryControlTapped control: UIControl) {
////        let location = view.annotation as! Artwork
////        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
////            MKLaunchOptionsDirectionsModeDriving]
////        location.mapItem().openInMaps(launchOptions: launchOptions)
//    }
//
//}




