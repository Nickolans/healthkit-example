//
//  ContentView.swift
//  healthkit-example
//
//  Created by Nickolans Griffith on 3/16/22.
//

import SwiftUI
import HealthKitUI

struct ContentView: View {
    
    var body: some View {
        
        Button {
            HealthManager.setup()
        } label: {
            Text("Activate HealthKit")
                .padding(15)
                .foregroundColor(.white)
                
        }
        .background(Color.blue.cornerRadius(15))
        .shadow(color: .gray, radius: 10, x: 0, y: 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
