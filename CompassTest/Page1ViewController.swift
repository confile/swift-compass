//
//  Page1ViewController.swift
//  CompassTest
//
//  Created by Michael Gorski on 21.07.15.
//  Copyright (c) 2015 Majestella. All rights reserved.
//

import UIKit
import CoreLocation

/**
*  See: http://stackoverflow.com/questions/4152003/how-can-i-get-current-location-from-user-in-ios
*/
class Page1ViewController: UIViewController, Test123Delegate {
  
  var geoPointCompass: GeoPointCompass!
  var distanceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.brownColor()
    
    // Create the image for the compass
    let arrowImageView: UIImageView = UIImageView(frame: CGRectMake(100, 200, 100, 100))
    arrowImageView.image = UIImage(named: "arrow.png")
    self.view.addSubview(arrowImageView)
    arrowImageView.center = self.view.center
    
    
    geoPointCompass = GeoPointCompass()
    geoPointCompass.delegate = self
    
    // Add the image to be used as the compass on the GUI
    geoPointCompass.arrowImageView = arrowImageView
    
    // Set the coordinates of the location to be used for calculating the angle
    geoPointCompass.latitudeOfTargetedPoint = CLLocationDegrees(53.557257)
    geoPointCompass.longitudeOfTargetedPoint = CLLocationDegrees(9.968518)
    geoPointCompass.targetLocation = CLLocation(latitude: geoPointCompass.latitudeOfTargetedPoint!, longitude: geoPointCompass.longitudeOfTargetedPoint!)
    
    
    distanceLabel = UILabel()
    distanceLabel.text = "0km"
    distanceLabel.sizeToFit()
    self.view.addSubview(distanceLabel)
    distanceLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y+100)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if CLLocationManager.locationServicesEnabled() {
      geoPointCompass.locationManager.startUpdatingLocation()
      geoPointCompass.locationManager.startUpdatingHeading()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    geoPointCompass.locationManager.stopUpdatingHeading()
    geoPointCompass.locationManager.stopUpdatingLocation()
  }
  
  
  // MARK: TestDelegate
  
  func onUpdate(text: String) {
    self.distanceLabel.text = text
    distanceLabel.sizeToFit()
  }
  
  
}


protocol Test123Delegate: class {
  
  func onUpdate(text: String)
  
}




class GeoPointCompass : NSObject, CLLocationManagerDelegate {
  
  weak var delegate: Test123Delegate?
  private(set) var locationManager:CLLocationManager
  var arrowImageView: UIImageView?
  var latitudeOfTargetedPoint: CLLocationDegrees?
  var longitudeOfTargetedPoint: CLLocationDegrees?
  var targetLocation: CLLocation?
  private var angle:    Float = 0
  
  override init() {
    self.locationManager = CLLocationManager()
    super.init()
    
    if CLLocationManager.locationServicesEnabled() {
      // Configure and start the LocationManager instance
      self.locationManager.delegate = self
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      self.locationManager.distanceFilter = 10
    }
  }
  
  // MARK: Private methods
  
  private func degreesToRadians(degrees: Float) -> Float {
    return degrees * Float(M_PI) / 180
  }
  
  
  // Caculate the angle between the north and the direction to observed geo-location
  private func calculateAngle(userlocation: CLLocation) -> Float {
    
    let userLocationLatitude: Float = degreesToRadians(Float(userlocation.coordinate.latitude))
    let userLocationLongitude: Float = degreesToRadians(Float(userlocation.coordinate.longitude))
    
    let targetedPointLatitude: Float = degreesToRadians(Float(self.latitudeOfTargetedPoint ?? 0))
    let targetedPointLongitude: Float = degreesToRadians(Float(self.longitudeOfTargetedPoint ?? 0))
    
    var longitudeDifference: Float = targetedPointLongitude - userLocationLongitude
    
    var y: Float = sin(longitudeDifference) * cos(targetedPointLatitude)
    var x: Float = cos(userLocationLatitude) * sin(targetedPointLatitude) - sin(userLocationLatitude) * cos(targetedPointLatitude) * cos(longitudeDifference)
    var radiansValue: Float = atan2(y, x)
    if(radiansValue < 0.0)
    {
      radiansValue += 2 * Float(M_PI)
    }
    
    return radiansValue
  }
  
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    let currentUserLocation = locations.last as! CLLocation
    
    var meters: CLLocationDistance = currentUserLocation.distanceFromLocation(targetLocation)
    var unit: String = "m"
    if meters > 1000 {
      meters = meters / 1000
      unit = "km"
    }
    
    let numberFormater = NSNumberFormatter()
    numberFormater.locale = NSLocale.currentLocale()
    numberFormater.numberStyle = NSNumberFormatterStyle.DecimalStyle
    if unit == "m" {
      numberFormater.maximumFractionDigits = 0
      numberFormater.minimumFractionDigits = 0
    }
    else {
      numberFormater.maximumFractionDigits = 2
      numberFormater.minimumFractionDigits = 0
    }
//    numberFormater.minimumFractionDigits = meters - Double(Int(meters)) == 0 ? 0 : 2
    let meterString = numberFormater.stringFromNumber(meters) ?? ""
    
    println("Distance: \(meterString)\(unit)")
    delegate?.onUpdate("\(meterString)\(unit)")
    
  }

  
  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("Erros: \(error.localizedDescription)")
  }
  
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    println("locationManager didChangeAuthorizationStatus")
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
    
    var direction: Float = Float(newHeading.magneticHeading)
    
    if direction > 180 {
      direction = 360 - direction
    }
    else {
      direction = 0 - direction
    }
    
    // Rotate the arrow image
    if let arrowImageView = self.arrowImageView {
      UIView.animateWithDuration(3.0, animations: { () -> Void in
        arrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(self.degreesToRadians(direction) + self.angle))
   
      })
    }
    
    let currentLocation: CLLocation = manager.location
  }
  
  
 
  
  
}