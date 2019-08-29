//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "bb6c8a458bd00e5959299f78f7068119"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    // os parametros vem do dicionario que foi criado usando a data no LOCATIONMANAGER
    //Write the getWeatherData method here: para criar o metodo eh escrever func
    
    func getWeatherData(url : String, parameters: [String : String]) {
        
        //o request precisa de inputs que seria o url, metodo e parametros. O input URL vem do GETWEATHERDATA (WEATHER_URL) o .get 'e um HTTPMethods que dita o que queremos fazer com o DATA SERVER. Os Parameters sao especificados na documentacao do site open weather map
        
        //estamos usando alguns inputs que seriam os URL e parametros que foram criados no LocationManager, entao teremos uma resposta do server e checaremos se a resposta sera ou nao um sucesso, se nao for, impriremos o erro no console e diremos ao usuario que ha Connection Issues
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON {
            response in // sempre que houver um in , devera haver um self
            if response.result.isSuccess {
                print("Sucess, got the weather data")
                //formatando a data que recebemos do open weather
                //no codigo a seguir sera uma optional, dessa forma, faremoss um force unwrapping para definir que o resultado seja um sucesso

                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData (json : JSON) {
        //eh preciso mostrar todo o "endereco" da informacao. Encontre todo o json e busque a palavra-chave main e em temp.
        // o .double converte o int em double
        if let tempResult = json ["main"]["temp"].double {
        //converte kelvin em graus, fore unwrapping pode quebrar o app, por isso usamos o binding que significa colocar o if let na funcao e tirar o ponto de exclamacao e fazer um else para indicar o erro
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city = json ["name"].stringValue
        
        weatherDataModel.condition = json ["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        //ira fazer a atualizacao 
        updateUIWithWeatherData()
    }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    //MARK: - UI Updates
    /***************************************************************/
    //atualizar a interface do usuario. aparecera no city label a cidade, no temperature label a temperatura e no weather icon a imagem do clima
    func updateUIWithWeatherData (){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        
        
    }
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        // garantindo que sera um valor valido
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()//para de procurar valores assim que obter os valores validos
            locationManager.delegate = nil
            
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            //fazer uma requisicao getWeatherData eh um metodo, um input eh o url : WEATHER_URL e o seguno input eh o parametro
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        //o q esta especificado no site do weather
        let params : [String:String] = ["q":city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue : UIStoryboardSegue, sender : Any?) {
        
        if segue.identifier == "changeCityName"{
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
        
    }
    
    
    
    
}


