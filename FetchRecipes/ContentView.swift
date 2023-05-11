//
//  ContentView.swift
//  FetchRecipes
//
//  Created by Maveric Vertudez on 5/11/23.
//

import SwiftUI

struct Recipes: Codable {
    var recipes: [Recipe]
}

struct Recipe: Hashable, Codable {
    var mealName: String
    var mealImage: String
    var mealID: String
}

struct ContentView: View {
    @State private var recipes = [Recipe]()
    var body: some View {
        NavigationView {
            List {
                ForEach(recipes, id: \.self) { recipe in
                    HStack {
                        Text(recipe.mealName)
                    }
                    
                }
            }
        }
        .task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([String: [Recipe]].self, from: data) {
                recipes = decodedResponse["meals"]!
            }
        } catch {
            print("ERROR: ", error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
