//
//  MainView.swift
//  MapAnnotation
//
//  Created by Alexander Bonney on 6/13/21.
//
import LocalAuthentication
import SwiftUI
import MapKit

struct MainView: View {
    @State private var isUnlocked = false
    @StateObject var vm = Places()
    var body: some View {
        VStack {
            if isUnlocked {
                TabView {
                MapView(vm: vm)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }

                ListView(vm: vm)
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }.onAppear(perform: {
                        vm.places.sort()
                    })
                }
            } else {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2959289849, green: 0.9137550592, blue: 0.9049167037, alpha: 1)), Color(#colorLiteral(red: 0.01941869408, green: 0.9847558141, blue: 0.2341538966, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                    VStack {
                        
                        Text("Bucket List")
                            .font(.system(size: 50))
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 15)
                            .padding(.top, 40)
                        Spacer()
                        
                    }
                    Button(action: {
                        withAnimation {
                            authenticate()
                        }
                    }, label: {
                        VStack {
                            Image(systemName: "faceid")
                                .font(.system(size: 100))
                                .padding()
                            Text("Tap to unlock")
                                .font(.headline)
                                .padding(.bottom)
                        }.padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(30)
                        .foregroundColor(.white)
                    })
                }
            }
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Use FaceID to get your places in safe"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    } else {
                        //error
                    }
                }
            }
            
        } else {
            //user's device has no faceID
        }
        
    }
}

struct MapView: View {
    @State private var showingAddingSheet = false
    @State private var showingEditView = false
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var showingInformation = false
    @ObservedObject var vm: Places
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009033),
        span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
    
    
  
    var body: some View {
        ZStack {
            JustMapView(region: $region, userTrackingMode: $userTrackingMode, showingInformation: $showingInformation, vm: vm)
            
            //current location
            LocationView(region: $region)
            
            CenterPointerView()
            
            PlusButtonView(region: $region, showingAddingSheet: $showingAddingSheet, vm: vm)
        }
        .alert(isPresented: $showingInformation, content: {
            Alert(title: Text(vm.place.name),message: Text(vm.place.description), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                // edit this place
                showingEditView = true
            })
        })
        .sheet(isPresented: $showingAddingSheet, content: {
            AddView(vm: vm)
        })
        .sheet(isPresented: $showingEditView, content: {
            EditView(vm: vm, place: vm.place)
        })
        
    }
}


struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView()
    }
}

struct JustMapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var userTrackingMode: MapUserTrackingMode
    @Binding var showingInformation: Bool
    @ObservedObject var vm: Places
    
    var body: some View {
        Map(coordinateRegion: $region, interactionModes: MapInteractionModes.all, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: vm.places) { place in
            // Insert an annotation type here
            MapAnnotation(coordinate: place.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                Button(action: {
                    vm.place = place
                    showingInformation = true
                }, label: {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                    //                            .shadow(radius: 10)
                    //                            .offset(x: 0, y: -15.0)
                })
            }
            //                MapPin(coordinate: place.coordinate)
        }
        .ignoresSafeArea(.all)
    }
}

struct LocationView: View {
    @Binding var region: MKCoordinateRegion
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack{
                    Text("Latitude: ")
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(region.center.latitude)")
                } //: HSTACK
                
                Divider().background(Color.white)
                
                HStack{
                    Text("Longitude: ")
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(region.center.longitude)")
                    
                }
            }
            .foregroundColor(.white)
            .font(.footnote)
            .padding()
            .background(
                Color.black
                    .cornerRadius(8)
                    .opacity(0.35)
            )
            .padding()
            Spacer()
        }
    }
}

struct CenterPointerView: View {
    var body: some View {
        Circle()
            .fill(Color.blue)
            .opacity(0.3)
            .frame(width: 32, height: 32)
    }
}

struct PlusButtonView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var showingAddingSheet: Bool
    @ObservedObject var vm: Places
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // create a new location
                    let newPlace = Place(name: "", description: "", latitude: region.center.latitude, longitude: region.center.longitude)
                    vm.place = newPlace
                    showingAddingSheet = true
                }) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                }
                
                Spacer()
            }.padding()
        }
    }
}
