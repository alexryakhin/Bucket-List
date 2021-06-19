//
//  DetailView.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/15/21.
//

import SwiftUI

struct DetailView: View {
    
    var place: Place
    
    var body: some View {
        Text(place.description)
            .navigationBarTitle(place.name, displayMode: .inline)
            
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(place: Place(name: "New York", description: "The United States", latitude: 40.7, longitude: -70))
    }
}
