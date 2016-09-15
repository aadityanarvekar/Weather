//
//  DownloadWeather.swift
//  Weather
//
//  Created by AADITYA NARVEKAR on 9/6/16.
//  Copyright © 2016 Aaditya Narvekar. All rights reserved.
//

import Foundation
import CoreLocation

class DownLoadWeather {
    
    let API_KEY = "6b7acabdde09ef1c4a0f79bed12ebba3"
    let URL_BASE = "http://api.openweathermap.org/"
    let URL_PATH = "data/2.5/weather?"
    
    static var instance = DownLoadWeather()
    private var _downloadUrl: NSURL!
    
    func downloadWeatherData(coordinates: CLLocationCoordinate2D, handler: ((NSData?, NSURLResponse?, NSError?) -> Void)) {
        //http://api.openweathermap.org/data/2.5/weather?lat=19.0176147&lon=72.8561644&appid=6b7acabdde09ef1c4a0f79bed12ebba3
        let downloadUrl = "\(URL_BASE)\(URL_PATH)lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)"
        print(downloadUrl)
        _downloadUrl = NSURL(string: downloadUrl)
        NSURLSession.sharedSession().dataTaskWithURL(_downloadUrl, completionHandler: handler).resume()
    }
    
}