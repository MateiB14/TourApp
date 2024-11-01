import Foundation
import CoreLocation

struct Landmark: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

