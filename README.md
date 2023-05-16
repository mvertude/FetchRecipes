# FetchRecipes
This project performs API calls from TheMealDB to display their dessert items along with their recipes. 

## Description
FetchRecipes is an iOS application built with Swift and SwiftUI. When first opening the app, the user will find a list of different desserts and their thumbnail images in alphabetical order. Upon clicking on one of the desserts, they will be navigated to a new view, showing a larger dessert image along with the recipe's ingredients, measurements, and step-by-step instructions.

## Getting Started
### Prerequisites
* MacOS compatible device
* Xcode 14.3 and above

### Installation
1. Clone the project onto your local machine using `git clone https://github.com/mvertude/FetchRecipes.git` in your terminal at your desired directory. Alternatively, you may download the project zip file then extract it onto your computer at your chosen location.
2. Start up Xcode then open the project file by navigating to the Menu Bar > File > Open... > FetchRecipes location.
3. On a fresh install, there should currently be "No Scheme" at the top of your Xcode project window. Click on that text, then click on "New Scheme...". A popup window should come up where you can leave all the values as default, then click "OK".

### Execution
1. Once there is a Scheme in place for the project, we can begin simulation. At the current scheme, select an iPhone device to run the simulation on.
2. Press `Cmd + R` to begin the simulation.

## Running the tests
There are some unit tests in place to ensure that data is being properly fetched from the API then altered accordingly for display in the views. You may press `Cmd + U` to run these tests. 
