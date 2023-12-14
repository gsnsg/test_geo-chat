//
//  LocationViewModel.swift
//  Geo Chat
//
//  Created by Sai Nikhit Gulla on 08/02/21.
//

import Foundation
import Combine
import CoreLocation
import Firebase
import GeoFire


class LocationManager: NSObject, ObservableObject{
    
    
    @Published var nearByUsers: [String] = []
    @Published var userVM: [String : ChatViewModel] = [:]
    
    
    private var userEnteredRefHandle: DatabaseHandle?
    private var geoQuery: GFCircleQuery?
    
    private var userExitedRefHandle: DatabaseHandle?

    private var username = UserDefaults.standard.value(forKey: "username") as! String
    
    
    private let geoFire = GeoFire(firebaseRef: Database.database().reference().child("/geo-locations/"))
    private let locationManager = CLLocationManager()
    
    
    private var lastKnowLocation = CLLocation(latitude: 0, longitude: 0)
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    func updateLocation(location: CLLocation) {
        geoFire.setLocation(location, forKey: username)
    }
    
    
    func removeLocation() {
        print("Removing Location!!!!!")
        geoFire.removeKey(username)
        FirebaseAuthManager.shared.signOutUser()
        stopListening()
    }
    
    
    
    func startListening() {
        geoQuery = geoFire.query(at: lastKnowLocation, withRadius: 1)
        
        userEnteredRefHandle = geoQuery?.observe(.keyEntered, with: { [weak self] (key, location) in
            if key != self?.username {
                let newVM = ChatViewModel(sender: self?.username ?? "", receiver: key)
                self?.nearByUsers.append(key)
                self?.userVM[key] = newVM
                print("Found User: " , key)
            }
        })
        userExitedRefHandle = geoQuery?.observe(.keyExited, with: { [weak self] (key, location) in
            print("Exited:", key)
            self?.nearByUsers.removeAll(where: { (user) -> Bool in
                key == user
            })
            self?.userVM.removeValue(forKey: key)
            print("Exited: ", key)
        })
        
        print("**** Started Listening GeoFire! ****")
        
    }
    
    func stopListening() {
        if self.geoQuery != nil {
            self.geoQuery!.removeObserver(withFirebaseHandle: userEnteredRefHandle!)
            self.geoQuery!.removeObserver(withFirebaseHandle: userEnteredRefHandle!)
        }
        print("**** Stopped Listening GeoFire! ****")
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        if currentLocation.distance(from: lastKnowLocation) > 150 {
            print("----In Here ----- ")
            lastKnowLocation = currentLocation
            updateLocation(location: lastKnowLocation)
            print(lastKnowLocation)
            self.stopListening()
            self.startListening()
        }
    }
}
