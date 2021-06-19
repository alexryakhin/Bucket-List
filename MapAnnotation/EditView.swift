//
//  EditView.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/15/21.
//

import SwiftUI

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: Places
    var place: Place
    @State private var nameField = ""
    @State private var descriptionField = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $nameField)
                    TextField("Description", text: $descriptionField)
                }
            }
            .navigationTitle("Edit place")
            .navigationBarItems(trailing: Button("Done") {
                
                
                if let chosenIndex = vm.places.firstIndex(matching: place) {
                    vm.places[chosenIndex].name = nameField
                    vm.places[chosenIndex].description = descriptionField
                }
                self.presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: {
                nameField = place.name
                descriptionField = place.description
            })
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(vm: Places(), place: Place(name: "New York", description: "The United States", latitude: 40.7, longitude: -70))
    }
}
