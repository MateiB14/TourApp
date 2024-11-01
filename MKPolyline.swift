import SwiftUI
import MapKit

struct MapPolyline: Shape {
    let route: MKRoute
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            var points = route.polyline.points()
            let pointCount = route.polyline.pointCount
            
            guard pointCount > 0 else { return }
            
            let start = points[0]
            path.move(to: CGPoint(x: CGFloat(start.x), y: CGFloat(start.y)))
            
            for i in 1..<pointCount {
                let point = points[i]
                path.addLine(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
            }
        }
    }
}
