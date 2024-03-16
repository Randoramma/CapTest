//
//  ContentView.swift
//  Capgamani
//
//  Created by Randy McLain on 3/15/24.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel: FetchImageModel = FetchImageModel()
    
    var body: some View {
 
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
            VStack {
                ExtractedView(image: viewModel.image)
            }
            .padding()
            .onAppear {
                Task {
                    do {
                        try await viewModel.updateImageForView(urlString: Constants.api)
                    } catch {
                        print(error)
                    }
                }
        }
        }
    }
}

#Preview {
    ContentView()
}

struct ExtractedView: View {
    
    @State private var textField1: String = "100"
    @State private var textField2: String = "100"
    private let viewImage: UIImage?
    
    init(image: UIImage?) {
        self.viewImage = image
    }
    
    var body: some View {
        Text(verbatim: "Please enter integers to resize image")
        SafeNumberTextField(text: $textField1, placeholderText: "Width")
            .padding(.leading)
            .background(Color.gray)
            .font(.largeTitle)
            .cornerRadius(5.0)
        SafeNumberTextField(text: $textField2, placeholderText: "Height")
            .padding(.leading)
            .background(Color.gray)
            .font(.largeTitle)
            .cornerRadius(5.0)
        Image(uiImage: viewImage ?? loadPlaceholderImage())
            .resizable()
            .frame(width:convertStringToCGFloat(sizeString: textField1))
            .frame(height: convertStringToCGFloat(sizeString: textField2))
            .onTapGesture {
                dismissKeyboard()
            }
        Spacer()
        Button("resetButton") {
            textField1 = "100"
            textField2 = "100"
        }
        .foregroundColor(.gray)
    }
    
    func loadPlaceholderImage() -> UIImage {
        guard let image =  UIImage(named: "JIB") else {
            fatalError("Must check the assets before deploying")
        }
        return image
    }
    
    func convertStringToCGFloat(sizeString: String) -> CGFloat? {
        guard let floatValue = Float(sizeString) else {
                return nil
            }
            return CGFloat(floatValue)
    }
    
    fileprivate func SafeNumberTextField(text: Binding<String>,
                                         placeholderText: String) -> some View {
        return TextField(placeholderText, text: text)
            .keyboardType(.numberPad)
            .onReceive(textField2.publisher.collect()) {
                self.textField2 = String($0).filter { "0123456789".contains($0) }
            }
    }
}

extension View {
    fileprivate func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
