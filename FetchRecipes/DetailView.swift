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
                .padding(20)
                .shadow(radius: 5)
                
                
                // Displays cooking instructions
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { i, content in
                            Text(String(i + 1) + ". " + content + ((i == recipe.instructions.count - 1) ? "" : "."))
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    .background(Color.indigo)
                    .cornerRadius(10)
                } header: {
                    Text("Instructions")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Display ingredients and their measurements
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(recipe.ingredientsAndMeasurements, id: \.self) { ingr in
                            Text("• " + ingr)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    .background(Color.indigo)
                    .cornerRadius(10)
                } header: {
                    Text("Ingredients")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
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

