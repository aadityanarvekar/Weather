//
//  ViewController.swift
//  Weather
//
//  Created by AADITYA NARVEKAR on 8/26/16.
//  Copyright © 2016 Aaditya Narvekar. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation = CLLocation()
    let geoCoder: CLGeocoder = CLGeocoder()
    var lastUpdatedDate: NSDate = NSDate()
    var isTemperatureInCelsiuis: Bool = true

    @IBOutlet weak var currentCityLbl: UILabel!
    @IBOutlet weak var currentStateAndCountryLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    
    var weather: CurrentWeather!
    
    let unitFlags: NSCalendarUnit = [.Weekday, .Month, .Year, .Hour, .Minute]
    let WAIT_PERIOD: NSTimeInterval = 5 * 60
    
    
    @IBOutlet weak var weatherIndicatorImg: UIImageView!
    @IBOutlet weak var weatherDescriptionLbl: UILabel!
    @IBOutlet weak var currentTemperatureLbl: UILabel!
    @IBOutlet weak var minTemperatureLbl: UILabel!
    @IBOutlet weak var maxTemperatureLbl: UILabel!
    @IBOutlet weak var currentWindSpeedLbl: UILabel!
    @IBOutlet weak var currentHumidityLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        requestAccessToUserLocation()
        locManager.startUpdatingLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.startUpdatingUserLocation), name: UIApplicationDidBecomeActiveNotification, object: nil)
        //NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.startUpdatingUserLocation), userInfo: nil, repeats: true)
    }
    
    func requestAccessToUserLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locManager.startUpdatingLocation()
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
                locManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    func updateCurrentDateAndTime() {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(unitFlags, fromDate: date)
        
        let day: String = getWeekdayFromDateComponent(components.weekday)
        let month: String = getMonthFromMonthComponent(components.month)
//        let hour = components.hour
//        let minute = components.minute
        self.dateTimeLbl.text = "\(day), \(month) \(components.year)"
    }
    
    func getWeekdayFromDateComponent(dayComp: Int) -> String {
        var day: String = ""
        
        switch dayComp {
        case 1:
            day = "Sunday"
        case 2:
            day = "Monday"
        case 3:
            day = "Tuesday"
        case 4:
            day = "Wednesday"
        case 5:
            day = "Thursday"
        case 6:
            day = "Friday"
        case 7:
            day = "Saturday"
        default:
            break
        }
        
        return day
    }
    
    func getMonthFromMonthComponent(monthComp: Int) -> String {
        var month = ""
        
        switch monthComp {
        case 1:
            month = "January"
        case 2:
            month = "February"
        case 3:
            month = "March"
        case 4:
            month = "April"
        case 5:
            month = "May"
        case 6:
            month = "June"
        case 7:
            month = "July"
        case 8:
            month = "August"
        case 9:
            month = "September"
        case 10:
            month = "October"
        case 11:
            month = "November"
        case 12:
            month = "December"
        default:
            break
        }
        
        return month
    }
    
    func startUpdatingUserLocation() {
        updateCurrentDateAndTime()
        locManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locManager.startUpdatingLocation()
        }
        
        if status == CLAuthorizationStatus.Denied {
            let alert = UIAlertController(title: "Weather", message: "Access to location is needed to provide accurate weather forecast", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Grant access", style: .Default, handler: { (action: UIAlertAction) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateCurrentDateAndTime()
        
        guard let loc = locations.last where (userLocation.distanceFromLocation(loc) != 0 || -lastUpdatedDate.timeIntervalSinceNow >= WAIT_PERIOD) else { return }
        userLocation = loc
        lastUpdatedDate = NSDate()
        
        DownLoadWeather.instance.downloadWeatherData(userLocation.coordinate) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if error == nil {
                self.setCurrentWeather(data!)
                dispatch_async(dispatch_get_main_queue(), { 
                    self.updateWeatherForecast()
                })
            } else {
                print("Error downloading weather data: \(error)")
            }
        }
        
        geoCoder.reverseGeocodeLocation(userLocation) { (placemarks: [CLPlacemark]?, err: NSError?) in
            if err == nil {
                for place in placemarks! {
                    if let cty = place.locality, let state = place.administrativeArea, let country = place.country {
                        self.currentCityLbl.text = cty
                        self.currentStateAndCountryLbl.text = "\(state), \(country)"
                    }
                }
            } else {
                print(err?.description)
            }
        }
        
    }
    
    private func setCurrentWeather(weatherData: NSData) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: .AllowFragments)
            if let dict = json as? Dictionary<String, AnyObject> {
                
                // Current Temp, min temperature, max temperature, humidity & pressure
                if let main = dict["main"] as? Dictionary<String, AnyObject> {
                    var currentTemp: Float = -9999
                    var minTemp: Float = -9999
                    var maxTemp: Float = -9999
                    if let temp = main["temp"] as? Float {
                        currentTemp = temp
                    }
                    
                    if let min = main["temp_min"] as? Float {
                        minTemp = min
                    }
                    
                    if let max = main["temp_max"] as? Float {
                        maxTemp = max
                    }
                    
                    if currentTemp != -9999 && minTemp != -9999 && maxTemp != -9999 {
                        self.weather = CurrentWeather(currentTemp: currentTemp, minTemp: minTemp, maxTemp: maxTemp)
                    } else {
                        print("Error getting weather conditions.")
                        return
                    }
                    
                    if let press = main["pressure"] as? Float {
                        self.weather.pressure = press
                    }
                    
                    if let humid = main["humidity"] as? Float {
                        self.weather.humidity = humid
                    }
                    
                    print("Weather should be initialized now")
                }
                
                // Weather description & icon
                if let weather = dict["weather"]![0] as? Dictionary<String, AnyObject> {
                    if let desc = weather["description"] as? String {
                        self.weather.weatherDescription = desc
                    }
                    
                    if let icon = weather["icon"] as? String {
                        self.weather.weatherIcon = icon
                    }
                }
            }
        } catch let err as NSError {
            print("Error parsing Weather Data: \(err)")
        }
    }
    
    func updateWeatherForecast() {
        self.weatherDescriptionLbl.text = self.weather.weatherDescription.capitalizedString
        self.weatherIndicatorImg.image = UIImage(named: "\(self.weather.weatherIcon!).png")
        updateTemperatureLabels()
        self.currentHumidityLbl.text = "\(self.weather.getCurrentHumidity())"
        self.currentWindSpeedLbl.text = "\(self.weather.getCurrentPressure())"
    }
    
    @IBAction func switchTemperatureUnits(sender: AnyObject) {
        if let btn = sender as? UIButton {
            if isTemperatureInCelsiuis {
                btn.setImage(UIImage(named: "celsius"), forState: .Normal)
                isTemperatureInCelsiuis = false
            } else {
                btn.setImage(UIImage(named: "farenheit"), forState: .Normal)
                isTemperatureInCelsiuis = true
            }
            updateTemperatureLabels()
        }
        
    }
    
    private func updateTemperatureLabels() {
        if isTemperatureInCelsiuis {
            self.currentTemperatureLbl.text = "\(self.weather.getCurrentTempInCelsius())"
            self.minTemperatureLbl.text = "\(self.weather.getMinTempInCelsius())"
            self.maxTemperatureLbl.text = "\(self.weather.getMaxTempInCelsius())"
        } else {
            self.currentTemperatureLbl.text = "\(self.weather.getCurrentTempInFarenheit())"
            self.minTemperatureLbl.text = "\(self.weather.getMinTempInFarenheit())"
            self.maxTemperatureLbl.text = "\(self.weather.getMaxTempInFarenheit())"
        }
    }
    

}

