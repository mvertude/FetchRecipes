//
//  ContentView.swift
//  FetchRecipes
//
//  Created by Maveric Vertudez on 5/11/23.
//

import SwiftUI

struct Dessert: Hashable, Codable {
    var strMeal: String
    var strMealThumb: String
    var idMeal: String
}

struct ContentView: View {
    @State private var recipes = [Dessert]()
    var body: some View {
        NavigationView {
            List {
                // Displays meals in alphabetic order
                ForEach(recipes.sorted(by: { $0.strMeal < $1.strMeal}) , id: \.self) { recipe in
                    NavigationLink {
                        DetailView(dessert: recipe)
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: recipe.strMealThumb)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 110, height: 110)
                            VStack {
                                Text(recipe.strMeal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 10)
                        }
                    }
                }
            }
            .navigationTitle("Desserts")
        }
        .task {
            await recipes = fetch()
        }
    }
    
    // Fetches all dessert values from TheMealDB API
    func fetch() async -> [Dessert] {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([String: [Dessert]].self, from: data) {
                return decodedResponse["meals"]!
            }
        } catch {
            print(error)
        }
        return []
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
