import Foundation

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let landmarks: [Landmark]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}
