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
//                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
                Group {
                    // Displays cooking instructions
                    Section {
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { i, content in
                            if content != "" {
                                Text(String(i + 1) + ". " + content + ((i == recipe.instructions.count - 1) ? "" : "."))
                                    .padding([.bottom], 1)
                            }
                        }
                    } header: {
                        Text("Instructions")
                            .font(.title)
                    }
                    
                    // Display ingredients and their measurements
                    Section {
                        ForEach(Array(recipe.ingredientsToMeasurements.keys), id: \.self) { key in
                            HStack {
                                Text(recipe.ingredientsToMeasurements[key]!)
                                
                            }
                        }
                    } header: {
                        Text("Ingredients")
                            .font(.title)
                            
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .navigationTitle(dessert.strMeal)
        .navigationBarTitleDisplayMode(.inline)
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
                
                // Removes leading/trailing whitespace, unecessary newlines, and empty strings
                recipe.instructions = dict["strInstructions"]!!.replacingOccurrences(of: "\r\n", with: " ").replacingOccurrences(of: "[0-9]\\. ", with: " ", options: .regularExpression).components(separatedBy: ". ")/*.filter({$0 != ""})*/.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                
                // Accesses values by ingredient keys, sorting them by their ending number, ignoring invalid values
                recipe.ingredients = dict.filter({$0.key.hasPrefix("strIngredient") && $0.value != "" && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(13))! < Int($1.key.dropFirst(13))!}).map({$0.value!})
                
                // Accesses values by measurement keys, sorting them by their ending number, ignoring invalid values
                recipe.measurements = dict.filter({$0.key.hasPrefix("strMeasure") && $0.value != " " && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(10))! < Int($1.key.dropFirst(10))!}).map({$0.value!})
                
                // Maps ingredient values to their corresponding measurements
                for i in 0..<recipe.ingredients.count {
                    recipe.ingredientsToMeasurements["item" + String(i + 1)] = recipe.measurements[i].trimmingCharacters(in: .whitespaces) + " " + recipe.ingredients[i].trimmingCharacters(in: .whitespaces)
                }
            }
        } catch {
            print(error)
        }
    }
}

