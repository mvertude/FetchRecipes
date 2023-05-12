//
//  DetailView.swift
//  FetchRecipes
//
//  Created by Maveric Vertudez on 5/11/23.
//

import SwiftUI

struct Recipe: Codable {
    var instructions: [String] = []
    var ingredients: [String] = []
    var measurements: [String] = []
    var ingredientsToMeasurements: [String:String] = [:]
}

struct DetailView: View {
    let dessert: Dessert
    @State private var recipe = Recipe()
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
//                Text(recipe.instructions)
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { i, content in
                    if content != "" {
                        Text(String(i + 1) + ". " + content + ".")
                    }
                }
                ForEach(Array(recipe.ingredientsToMeasurements.keys), id: \.self) { key in
                    HStack {
                        Text(recipe.ingredientsToMeasurements[key]!)
                    }
                }
            }
        }
        .task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=" + dessert.idMeal) else {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([String:[[String: String?]]].self, from: data) {
                let dict = (decodedResponse["meals"]?[0])!
                recipe.instructions = dict["strInstructions"]!!.replacingOccurrences(of: "\r\n", with: "").components(separatedBy: ".")
                recipe.ingredients = dict.filter({$0.key.hasPrefix("strIngredient") && $0.value != "" && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(13))! < Int($1.key.dropFirst(13))!}).map({$0.value!})
                recipe.measurements = dict.filter({$0.key.hasPrefix("strMeasure") && $0.value != " " && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(10))! < Int($1.key.dropFirst(10))!}).map({$0.value!})
                for i in 0..<recipe.ingredients.count {
                    recipe.ingredientsToMeasurements["item" + String(i + 1)] = recipe.ingredients[i] + ", " + recipe.measurements[i]
                }
            }
        } catch {
            print(error)
        }
    }
}

