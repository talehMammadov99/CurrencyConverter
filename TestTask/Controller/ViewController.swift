//
//  ViewController.swift
//  TestTask
//
//  Created by Taleh Mammadov on 17.03.23.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let currencyPicker = UIPickerView()
    let fromCurrencyTextField = UITextField()
    let toCurrencyTextField = UITextField()
    let fromPriceTextField = UITextField()
    let toPriceTextField = UITextField()

    var currencyModel: [CurrencyValue]?
    var rateResponse: [CurrencyRateResponse]?
    
    override func loadView() {
        fetchData()
        view = UIView()
        
        fromCurrencyTextField.borderStyle = .roundedRect
        fromCurrencyTextField.placeholder = "From currency"
        
        toCurrencyTextField.borderStyle = .roundedRect
        toCurrencyTextField.placeholder = "To currency"
        
        fromPriceTextField.borderStyle = .roundedRect
        fromPriceTextField.placeholder = "From Price"
        fromPriceTextField.keyboardType = .numberPad
        
        toPriceTextField.borderStyle = .roundedRect
        toPriceTextField.placeholder = "To Price"
        
        currencyPicker.delegate = self
        fromCurrencyTextField.inputView = currencyPicker
        toCurrencyTextField.inputView = currencyPicker
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
        fromPriceTextField.inputAccessoryView = toolbar
        
        view.addSubview(fromCurrencyTextField)
        fromCurrencyTextField.translatesAutoresizingMaskIntoConstraints = false
        fromCurrencyTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        fromCurrencyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        fromCurrencyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        fromCurrencyTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(toCurrencyTextField)
        toCurrencyTextField.translatesAutoresizingMaskIntoConstraints = false
        toCurrencyTextField.topAnchor.constraint(equalTo: fromCurrencyTextField.bottomAnchor, constant: 20).isActive = true
        toCurrencyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        toCurrencyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        toCurrencyTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(fromPriceTextField)
        fromPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        fromPriceTextField.topAnchor.constraint(equalTo: toCurrencyTextField.bottomAnchor, constant: 20).isActive = true
        fromPriceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        fromPriceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        fromPriceTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(toPriceTextField)
        toPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        toPriceTextField.topAnchor.constraint(equalTo: fromPriceTextField.bottomAnchor, constant: 20).isActive = true
        toPriceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        toPriceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        toPriceTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    }
    
    @objc func doneButtonTapped() {
        getCurrencyRate(from: fromCurrencyTextField.text ?? "", to: toCurrencyTextField.text ?? "")
        fromPriceTextField.resignFirstResponder()
    }
    
    
    func fetchData() {
        let url = URL(string: "https://valyuta.com/api/get_currency_list_for_app")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let currencies = try decoder.decode([CurrencyValue].self, from: data)
                self.currencyModel = currencies
                print("Currencies: \(currencies)")
            } catch {
                print("Error currency list: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    func convertPrice() {
        guard let price = Double(fromPriceTextField.text ?? "") else {
            return
        }
        var currencyRate = 1.0
        if let response = rateResponse {
            for rate in response {
                if fromCurrencyTextField.text == rate.from {
                    currencyRate = rate.result
                }
            }
        }
        let convertedPrice = price * currencyRate
        let formattedPrice = String(format: "%.2f", convertedPrice)
        
        toPriceTextField.text = formattedPrice
    }
    
    func getCurrentDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let formattedDate = formatter.string(from: date)
        return formattedDate
    }
    
    func getCurrencyRate(from: String, to: String) {
        
        let url = URL(string: "https://valyuta.com/api/get_currency_rate_for_app/\(to)/\(getCurrentDateString())")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let rateResponse = try decoder.decode([CurrencyRateResponse].self, from: data)
                
                DispatchQueue.main.async {
                    self.rateResponse = rateResponse
                    self.convertPrice()
                }
            } catch {
                print("Error decoding currency rate: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencyModel?.count ?? 10
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyModel?[row].code
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if fromCurrencyTextField.isFirstResponder {
            fromCurrencyTextField.text = currencyModel?[row].code
        } else {
            toCurrencyTextField.text = currencyModel?[row].code
        }
    }
    
}
