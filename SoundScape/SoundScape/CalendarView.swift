//
//  CalendarView.swift
//  SoundScape
//
//  Created by 오도영 on 2/9/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var date = Date()
    
    var body: some View {
        DatePicker(
            "Start Date",
            selection: $date,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        
    }
}

#Preview {
    CalendarView()
}
