//
//  AddView.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/15/21.
//

import SwiftUI

struct AddView: View {
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()

    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: Places
    @State private var nameField = ""
    @State private var descriptionField = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $nameField)
                    TextField("Description", text: $descriptionField)
                }
                
                Section(header: Text("Nearby…")) {
                    if loadingState == .loaded {
                        List(pages, id: \.pageid) { page in
                            Button(action: {
                                nameField = page.title
                                descriptionField = page.description
                            }, label: {
                                Text(page.title)
                                    .font(.headline)
                                + Text(": ") +
                                Text(page.description)
                                    .italic()
                            }).buttonStyle(PlainButtonStyle())
                        }
                    } else if loadingState == .loading {
                        Text("Loading…")
                    } else {
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Add new place")
            .navigationBarItems(trailing: Button("Done") {
                if nameField.isEmpty {
                    vm.place.name = "New place"
                    vm.place.description = "Empty Description"
                } else {
                    vm.place.name = nameField
                    vm.place.description = descriptionField
                }
                vm.places.append(vm.place)
                self.presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: {
                nameField = vm.place.name
                descriptionField = vm.place.description
                fetchNearbyPlaces()
            })
        }
    }
    
    func fetchNearbyPlaces() {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(vm.place.latitude)%7C\(vm.place.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // we got some data back!
                let decoder = JSONDecoder()

                if let items = try? decoder.decode(Result.self, from: data) {
                    // success – convert the array values to our pages array
                    self.pages = Array(items.query.pages.values).sorted()
                    self.loadingState = .loaded
                    return
                }
            }

            // if we're still here it means the request failed somehow
            self.loadingState = .failed
        }.resume()
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(vm: Places())
    }
}
