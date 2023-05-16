//
//  DetailView.swift
//  FetchRecipes
//
//  Created by Maveric Vertudez on 5/11/23.
//

import SwiftUI

struct Recipe: Codable {
    var instructions: [String] = []
    var ingredientsAndMeasurements: [String] = []
}

enum Selection: String, CaseIterable, Identifiable {
    case ingredients, instructions
    var id: Self { self }
}

struct ListView: View {
    var selection: Selection
    var data: [String]
    
    var body: some View {
        if selection == .instructions {
            ForEach(Array(data.enumerated()), id: \.offset) { i, content in
                Text(String(i + 1) + ". " + content + ((i == data.count - 1) ? "" : "."))
                    
            }
        } else {
            ForEach(data, id: \.self) { ingr in
                Text(ingr)
            }
        }
    }
}

struct DetailView: View {
    let dessert: Dessert
    @State private var recipe = Recipe()
    @State private var selectedView: Selection = .ingredients
    var body: some View {
        List {
            Group {
                AsyncImage(url: URL(string: dessert.strMealThumb)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                }
                .shadow(radius: 5)
                
                Picker("Ingredients or Instructions", selection: $selectedView) {
                    ForEach(Selection.allCases) { select in
                        Text(select.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .listRowBackground(Color(UIColor.systemBackground))
            .listRowSeparator(.hidden)
            ListView(selection: selectedView, data: (selectedView == .ingredients) ? recipe.ingredientsAndMeasurements: recipe.instructions)
            
        }
        .task {
            await recipe = fetchDetails(id: dessert.idMeal)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.grouped)
        .navigationTitle(dessert.strMeal)
        .navigationBarTitleDisplayMode(.inline)
        .offset(y: -30)
    }
    
    func fetchDetails(id: String) async -> Recipe {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=" + id) else {
            return Recipe()
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([String:[[String: String?]]].self, from: data) {
                let dict = (decodedResponse["meals"]?[0])!
                
                // Separates instructions into a list of strings
                let instructions = stripInstructions(str: dict["strInstructions"]!!)
                
                // Accesses the ingredients and their corresponding measurements
                let ingredients: [String] = filterIngredients(dict: dict, prefix: "strIngredient")
                let measurements: [String] = filterIngredients(dict: dict, prefix: "strMeasure")
                
                // Concatenates ingredients and measurements together into a single string
                var ingredientsAndMeasurements: [String] = []
                for (ingredient, measurement) in zip(ingredients, measurements) {
                    ingredientsAndMeasurements.append(measurement + " " + ingredient)
                }
                
                return Recipe(instructions: instructions, ingredientsAndMeasurements: ingredientsAndMeasurements)
            }
        } catch {
            print(error)
        }
        return Recipe()
    }
    
    // Removes leading/trailing whitespace, unecessary newlines, and empty strings from instrs
    func stripInstructions(str: String) -> [String] {
        return str.replacingOccurrences(of: "\r\n", with: " ").replacingOccurrences(of: "\\w*(?<![Gg]as )[0-9]\\. ", with: ". ", options: .regularExpression).components(separatedBy: ". ").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter({$0 != ""})
    }
    
    // Helper function to filter out valid ingredients, removing empty/null values and whitespace
    func filterIngredients(dict: [String: String?], prefix: String) -> [String] {
        return dict.filter({$0.key.hasPrefix(prefix) && $0.value != "" && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(prefix.count))! < Int($1.key.dropFirst(prefix.count))!}).map({$0.value!.trimmingCharacters(in: .whitespaces)})
    }
}

