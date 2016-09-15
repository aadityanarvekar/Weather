//
//  CurrentWeather.swift
//  Weather
//
//  Created by AADITYA NARVEKAR on 9/6/16.
//  Copyright © 2016 Aaditya Narvekar. All rights reserved.
//

import Foundation

class CurrentWeather {
    private var _weatherDescription: String?
    var weatherDescription: String {
        get {
            if let desc = _weatherDescription {
                return desc
            } else {
                return ""
            }
        }
        set {
            if newValue.characters.count > 0 {
                _weatherDescription = newValue
            }
        }
    }
    
    var weatherIcon: String?
    
    private var _currentTemp: Float!
    var currentTemp: Float {
        get {
            if let temp = _currentTemp {
                return temp
            } else {
                return -9999
            }
        }
        set {
            if newValue > 0 {
                _currentTemp = newValue
            }
        }
    }
    
    private var _minTemp: Float!
    var minTemp: Float {
        get {
            if let temp = _minTemp {
                return temp
            } else {
                return -9999
            }
        }
        set {
            if newValue > 0 {
                _minTemp = newValue
            }
        }
    }
    
    private var _maxTemp: Float!
    var maxTemp: Float {
        get {
            if let temp = _maxTemp {
                return temp
            } else {
                return -9999
            }
        }
        set {
            if newValue > 0 {
                _maxTemp = newValue
            }
        }
    }
    
    private var _pressure: Float?
    var pressure: Float {
        get {
            if let press = _pressure {
                return press
            } else {
                return -9999
            }
        }
        set {
            if newValue > 0 {
                _pressure = newValue
            }
        }
    }
    
    private var _humidity: Float?
    var humidity: Float {
        get {
            if let hum = _humidity {
                return hum
            } else {
                return -9999
            }
        }
        set {
            if newValue > 0 {
                _humidity = newValue
            }
        }
    }
    
    init(currentTemp: Float, minTemp: Float, maxTemp: Float) {
        _currentTemp = currentTemp
        _minTemp = minTemp
        _maxTemp = maxTemp
    }
    
    func getCurrentTempInCelsius() -> String {
        return "\(Int(round(self.currentTemp - 273.15)))°C"
    }
    
    func getMinTempInCelsius() -> String {
        return "\(Int(round(self.minTemp - 273.15)))°C"
    }
    
    func getMaxTempInCelsius() -> String {
        return "\(Int(round(self.maxTemp - 273.15)))°C"
    }
    
    func getCurrentTempInFarenheit() -> String {
        return "\(Int(round(self.currentTemp - 273.15) * 1.8 + 32))°F"
    }
    
    func getMinTempInFarenheit() -> String {
        return "\(Int(round(self.minTemp - 273.15) * 1.8 + 32))°F"
    }
    
    func getMaxTempInFarenheit() -> String {
        return "\(Int(round(self.maxTemp - 273.15) * 1.8 + 32))°F"
    }
    
    func getCurrentHumidity() -> String {
        return "\(Int(round(self.humidity)))%"
    }
    
    func getCurrentPressure() -> String {
        return "\(Int(round(self.pressure))) hPA"
    }
    
}