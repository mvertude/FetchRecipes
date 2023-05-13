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
    //            .padding([.horizontal], 20)
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
            await fetch()
        }
        .scrollContentBackground(.hidden)
        .listStyle(.grouped)
        .navigationTitle(dessert.strMeal)
        .navigationBarTitleDisplayMode(.inline)
        .offset(y: -30)
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
                recipe.instructions = dict["strInstructions"]!!.replacingOccurrences(of: "\r\n", with: " ").replacingOccurrences(of: "\\w*(?<![Gg]as )[0-9]\\. ", with: ". ", options: .regularExpression).components(separatedBy: ". ").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter({$0 != ""})
                
                // Accesses values by ingredient keys, sorting them by their ending number, ignoring invalid values
                let ingredients = dict.filter({$0.key.hasPrefix("strIngredient") && $0.value != "" && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(13))! < Int($1.key.dropFirst(13))!}).map({$0.value!})
                
                // Accesses values by measurement keys, sorting them by their ending number, ignoring invalid values
                let measurements = dict.filter({$0.key.hasPrefix("strMeasure") && $0.value != " " && $0.value != nil}).sorted(by: { Int($0.key.dropFirst(10))! < Int($1.key.dropFirst(10))!}).map({$0.value!})
                
                // Adds ingredients and measurements together into a single string
                for i in 0..<ingredients.count {
                    recipe.ingredientsAndMeasurements.append(measurements[i].trimmingCharacters(in: .whitespaces) + " " + ingredients[i].trimmingCharacters(in: .whitespaces))
                }
            }
        } catch {
            print(error)
        }
    }
}

