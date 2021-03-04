//
//  ViewController.swift
//  Погода
//
//  Created by Аида on 4.03.21.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {

    // UI
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabelDiscription: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    
    // Data
    var weatherData = WeatherData()

    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
        
    }
    func updateViewController() {
        cityNameLabel.text = weatherData.name
        tempLabel.text = weatherData.main.temp.description + "°"
        weatherLabelDiscription.text = weatherData.weather[0].description
        weatherIconImage.image = UIImage(named: weatherData.weather[0].icon)
    }
    func startLocationManager() {
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            //если местоположение изменилось от предыдущей точки на сто метров тогда оно обновиться
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // что бы не выключался самостоятельно и не совершал паузы
            locationManager.pausesLocationUpdatesAutomatically = false
            //
            locationManager.startUpdatingLocation()
        }
    }
    func weatherInfo(latitude: Double ,longitude: Double) {
        // session
        let session = URLSession.shared
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longitude.description)&appid=\(apiKey.weatherApiKey)&units=metric&lang=ru") else {return}

        
        let task = session.dataTask(with: url) { (data , responce , error ) in
            guard error == nil else {
                print("Data task Error \(String(describing: error?.localizedDescription))")
                return
            }
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                print(self.weatherData)
                DispatchQueue.main.async {
                    self.updateViewController()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let mylocationLatitude = lastLocation.coordinate.latitude
            let mylocationLongitude = lastLocation.coordinate.longitude
            weatherInfo(latitude: mylocationLatitude, longitude: mylocationLongitude)
            print(mylocationLatitude)
            print(mylocationLongitude)

        }
    }
}

