//
//  PhoneNumberView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/26/22.
//

import SwiftUI

struct PhoneNumberView: View {
    
    let countryCodes = Constants.countryCodes
    @State var selectedCountryCode: CountryCode
    
    @State var phone = ""
    
    var isPhoneFieldFocused: FocusState<Bool>.Binding
    var onInputValueChange: (String, String) -> Void
    
    init(
        isPhoneFieldFocused: FocusState<Bool>.Binding,
        onInputValueChange: @escaping (String, String) -> Void
    ) {
        selectedCountryCode = countryCodes.first!
        self.onInputValueChange = onInputValueChange
        self.isPhoneFieldFocused = isPhoneFieldFocused
    }
    
    var body: some View {
        HStack {
            Picker("Select country code", selection: $selectedCountryCode) {
                ForEach(countryCodes, id: \.self) {
                    Text("\($0.flag) \($0.code)")
                }
            }
            .pickerStyle(.menu)
            .frame(width: 56)
            .formControlPrimary()
            .onChange(of: selectedCountryCode, perform: { onInputValueChange($0.code, phone) })
            
            TextField("5551234567", text: $phone)
                .keyboardType(.phonePad)
                .focused(isPhoneFieldFocused)
                .frame(maxWidth: .infinity)
                .formControlPrimary()
                .onChange(of: phone, perform: { onInputValueChange(selectedCountryCode.code, $0) })
        }
    }
}

struct Constants {
    static let countryCodes = [
        CountryCode(flag: "🇺🇸", code: "+1"),
        CountryCode(flag: "🇺🇦", code: "+38"),
    ]
}

struct CountryCode: Hashable {
    var flag: String
    var code: String
}
