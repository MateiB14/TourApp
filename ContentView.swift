import SwiftUI
import MapKit
import CoreLocationUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedCity: City?
    @State private var selectedLandmark: Landmark?
    @State private var showDirections = false

    let cities = [
        City(name: "Chicago", landmarks: [
            Landmark(name: "Willis Tower", coordinate: CLLocationCoordinate2D(latitude: 41.8789, longitude: -87.6359)),
            Landmark(name: "Millennium Park", coordinate: CLLocationCoordinate2D(latitude: 41.8826, longitude: -87.6226)),
            Landmark(name: "Navy Pier", coordinate: CLLocationCoordinate2D(latitude: 41.8919, longitude: -87.6051))
        ]),
        // Add more cities here
    ]

    var body: some View {
        NavigationView {
            VStack {
                if locationManager.locationStatus == .authorizedWhenInUse || locationManager.locationStatus == .authorizedAlways {
                    citySelectionView
                } else {
                    requestLocationView
                }
            }
            .navigationTitle("City Tour")
        }
    }

    private var citySelectionView: some View {
        VStack {
            Picker("Select a city", selection: $selectedCity) {
                Text("Choose a city").tag(nil as City?)
                ForEach(cities) { city in
                    Text(city.name).tag(city as City?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            if let city = selectedCity {
                List(city.landmarks) { landmark in
                    Button(landmark.name) {
                        selectedLandmark = landmark
                        showDirections = true
                    }
                }
            } else {
                Text("Please select a city")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .sheet(isPresented: $showDirections) {
            if let landmark = selectedLandmark, let userLocation = locationManager.lastLocation {
                DirectionsView(userLocation: userLocation, destination: landmark)
            }
        }
    }

    private var requestLocationView: some View {
        VStack {
            Text("We need your location to provide directions.")
                .padding()
            LocationButton(.currentLocation) {
                locationManager.requestLocation()
            }
            .frame(height: 44)
            .padding()
        }
    }
}
