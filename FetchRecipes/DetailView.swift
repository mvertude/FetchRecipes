//
//  DetailView.swift
//  FetchRecipes
//
//  Created by Maveric Vertudez on 5/11/23.
//

import SwiftUI

struct Recipe: Codable {
    var meals: [String: String?] // strInstructions, strIngredient[1:20], strMeasure[1:20]
}

struct DetailView: View {
    let dessert: Dessert
    @State private var recipe = Recipe(meals: [:])
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: dessert.strMealThumb)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
                Text(dessert.strMeal)
                Text((recipe.meals["strInstructions"] ?? "") ?? "")
                let ingredients = recipe.meals.filter({$0.key.hasPrefix("strIngredient") && $0.value != "" && $0.value != nil}).values
                ForEach(Array(ingredients), id: \.self) { ingredient in
                    Text(ingredient ?? "")
                }
            }
        }
        .task {
            await fetch()
            print(type(of: recipe.meals))
            print(recipe.meals)
        }
    }
    
    func fetch() async {
        print("fetching data...")
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=" + dessert.idMeal) else {
            return
        }
        print(url)
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([String:[[String: String?]]].self, from: data) {
                recipe.meals = (decodedResponse["meals"]?[0])!
            }
        } catch {
            print(error)
        }
    }
}

