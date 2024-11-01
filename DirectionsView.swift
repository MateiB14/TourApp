import SwiftUI
import MapKit

// Main DirectionsView
struct DirectionsView: View {
    let userLocation: CLLocationCoordinate2D
    let destination: Landmark
    @State private var directions: [String] = []
    @State private var route: MKRoute?
    @State private var region: MKCoordinateRegion
    @State private var showDirections = false

    init(userLocation: CLLocationCoordinate2D, destination: Landmark) {
        self.userLocation = userLocation
        self.destination = destination
        _region = State(initialValue: MKCoordinateRegion(
            center: destination.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    var body: some View {
        VStack {
            MapViewWrapper(region: $region, destination: destination, route: route)
                .frame(height: 300)

            Button("Get Directions") {
                calculateDirections()
                showDirections = true
            }
            .padding()

            if showDirections {
                DirectionsList(directions: directions)
            }
        }
        .navigationTitle("Directions to \(destination.name)")
        .onAppear(perform: calculateDirections)
    }

    private func calculateDirections() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .automobile

        Task {
            do {
                let result = try await MKDirections(request: request).calculate()
                if let route = result.routes.first {
                    self.route = route
                    self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
                    
                    let rect = route.polyline.boundingMapRect
                    region = MKCoordinateRegion(rect)
                }
            } catch {
                print("Error calculating directions: \(error.localizedDescription)")
            }
        }
    }
}

// MapViewWrapper for displaying the map and route
struct MapViewWrapper: View {
    @Binding var region: MKCoordinateRegion
    let destination: Landmark
    let route: MKRoute?

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [destination]) { place in
            MapMarker(coordinate: place.coordinate)
        }
        .overlay(RouteOverlay(route: route))
    }
}

// RouteOverlay for drawing the route on the map
struct RouteOverlay: View {
    let route: MKRoute?

    var body: some View {
        GeometryReader { geometry in
            if let route = route {
                Path { path in
                    var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: route.polyline.pointCount)
                    route.polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: route.polyline.pointCount))
                    
                    guard let start = coordinates.first else { return }
                    path.move(to: geometry.convert(start))
                    
                    for coordinate in coordinates.dropFirst() {
                        path.addLine(to: geometry.convert(coordinate))
                    }
                }
                .stroke(Color.blue, lineWidth: 5)
            }
        }
    }
}

extension GeometryProxy {
    func convert(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        let point = MKMapPoint(coordinate)
        return CGPoint(x: point.x, y: point.y)
    }
}

// DirectionsList for displaying step-by-step directions
struct DirectionsList: View {
    let directions: [String]

    var body: some View {
        List(directions, id: \.self) { direction in
            Text(direction)
        }
    }
}
