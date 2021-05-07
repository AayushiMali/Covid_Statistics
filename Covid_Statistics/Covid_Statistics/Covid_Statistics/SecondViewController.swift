//
//  SecondViewController.swift
//  FinalExam
//
//  Created by Student on 2020-04-21.
//  Copyright © 2020 Student. All rights reserved.
//
import UIKit
import CoreLocation
import Charts


class SecondViewController: UIViewController,CLLocationManagerDelegate {
    var currentLongitude: Double?
    var countryLocation : CLLocation?
    var currentLatitude: Double?
    let locationManager = CLLocationManager()
    var currentLocation : CLLocation?
    var lastLocation : CLLocation?
    var totalRecover: Int?
    var totalDeath: Int?
    var totalConfirm: Int?
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var totalCount: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryInput: UITextField!
    @IBOutlet weak var totalConfirmed: UILabel!
    @IBOutlet weak var deathCount: UILabel!
    @IBOutlet weak var recoveredCount: UILabel!
    @IBAction func searchBtn(_ sender: UIButton) {
        
        let urlString = "https://www.bing.com/covid/data"
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)
        if let url = url
        {
            let dataTask = urlSession.dataTask(with: url)
            {
                (data, respose, error) in
                if let data = data
                {
                    let jsonDecoder = JSONDecoder()
                    
                    do {
                        let readableData = try jsonDecoder.decode(Covid19.self, from: data)
                        self.displayCovidData(readableData)
                        self.displayChart(readableData)
                    }
                    catch
                    {
                        print("Unable to Decode data!!")
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last
        {
            currentLocation = location
            currentLatitude = location.coordinate.latitude
            currentLongitude = location.coordinate.longitude
            
        }
        else
        {
            print("location data not found...!")
        }
        
    }
    
    func displayCovidData(_ readableData: Covid19)
    {
        DispatchQueue.main.async
            {
                
                for i in 0..<readableData.areas.count
                {
                    self.countryLocation = CLLocation(latitude: readableData.areas[i].lat, longitude: readableData.areas[i].long)
                    
                    if(self.countryInput.text == readableData.areas[i].displayName)
                    {
                        self.countryName.text = String(readableData.areas[i].displayName)
                        self.totalConfirmed.text = String(readableData.areas[i].totalConfirmed)
                        self.recoveredCount.text = String(readableData.areas[i].totalRecovered!)
                        self.deathCount.text = String(readableData.areas[i].totalDeaths!)
                        self.totalConfirm = readableData.areas[i].totalConfirmed
                        self.totalRecover = readableData.areas[i].totalRecovered!
                        self.totalDeath = readableData.areas[i].totalDeaths!
                       
                    }
                }
                    
            }
                
    }
        
    
    
    func displayChart(_ readableData: Covid19){
        
        for i in 0..<readableData.areas.count
        {
            print(i)
            let x = 0.0
            let y = 0.0
            var d1: ChartDataEntry = BarChartDataEntry(x: x, y: y)
            var d2: ChartDataEntry = BarChartDataEntry(x: x, y: y)
            var d3: ChartDataEntry = BarChartDataEntry(x: x, y: y)
            if let totalConfirmed = self.totalConfirm{
             d1 = BarChartDataEntry(x: 1, y: Double(totalConfirmed))
            }
            if let totalRecovered =  self.totalRecover{
                     d2 = BarChartDataEntry(x: 2, y: Double(totalRecovered))
            }
            if let totalDeath = self.totalDeath{
                     d3 = BarChartDataEntry(x: 3, y: Double(totalDeath))
            }
                    let dataSet = BarChartDataSet(entries: [d1,d2,d3], label: "CovidData")
                    
                    dataSet.colors = [.systemIndigo,.systemGreen,.systemRed]
                    
                    let data = BarChartData(dataSet: dataSet)
                    
                    DispatchQueue.main.async {
                        
                        self.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["X axis","Y axis","Z axis"])
                        self.barChart.data = data
                    }
                
            }
    
    }


}
