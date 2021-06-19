//
//  ListView.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/14/21.
//

import SwiftUI

struct ListView: View {
    
    @ObservedObject var vm: Places
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(vm.places) { place in
                        NavigationLink(
                            destination: DetailView(place: place),
                            label: {
                                Text(place.name)
                            })
                    }.onDelete(perform: removePlaces)
                }
            }
            .navigationTitle("Bucket List")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func removePlaces(of offsets: IndexSet) {
        vm.places.remove(atOffsets: offsets)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(vm: Places())
    }
}
