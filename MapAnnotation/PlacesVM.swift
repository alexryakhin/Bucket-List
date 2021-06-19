//
//  PlacesVM.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/14/21.
//

import Foundation

class Places: ObservableObject {
    
    @Published var places = [Place]() {
        didSet {
            do {
                let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
                let places = try JSONEncoder().encode(self.places)
                try places.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
            
            // User Defaults
            
            //This takes four steps in total: we need to create an instance of JSONEncoder that will do the work of converting our data to JSON, we ask that to try encoding our items array, and then we can write that to UserDefaults using the key “Items”.
            /*
             
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(places) {
                        UserDefaults.standard.set(encoded, forKey: "Places")
            }
             
            */
        }
    }
    
    init() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        do {
            let places = try Data(contentsOf: filename)
            self.places = try JSONDecoder().decode([Place].self, from: places)
        } catch {
            print("Unable to load saved data.")
        }
        
        // User defaults
        /*
         
        if let places = UserDefaults.standard.data(forKey: "Places") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Place].self, from: places) {
                self.places = decoded
                return
            }
        }

        self.places = []
         
         */
    }
    
    var place = Place(name: "London", description: "England", latitude: 40.7, longitude: -70)
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return nil
    }
}

enum LoadingState {
    case loading, loaded, failed
}
