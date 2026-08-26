import SwiftUI
import Combine

struct TradeDetailView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @ObservedObject var currencyViewModel: CurrencyViewModel
    @StateObject private var tradeViewModel: TradeDetailViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var autoScrollIndex: Int = 0
    @State private var isUserInteracting: Bool = false
    @State private var interactionTimer: Task<Void, Never>? = nil
    private let autoScrollPublisher = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    init(currencyViewModel: CurrencyViewModel, initialCurrency: Currency) {
        self.currencyViewModel = currencyViewModel
        self._tradeViewModel = StateObject(wrappedValue: TradeDetailViewModel(initialCurrency: initialCurrency))
    }
    
    var body: some View {
        ZStack {
            AppTheme.background(isLiquid: isLiquidGlassEnabled)
            
            VStack(spacing: 0) {
                topBarSection
                
                currencyHorizontalStrip
                    .padding(.vertical, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        balanceInfoCard
                        rateInfoCard
                        amountInputCard
                        tradeActionButtons
                        
                        portfolioSummaryCard
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .alert("İşlem Sonucu", isPresented: $tradeViewModel.showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(tradeViewModel.alertMessage)
        }
    }
    
    private var topBarSection: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.down")
                    Text("Kapat")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textTertiary(isLiquid: isLiquidGlassEnabled))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(getCardBackground())
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.05), radius: 4)
            }
            
            Spacer()
            
            Text("\(tradeViewModel.selectedCurrency.id) / TRY")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppTheme.textPrimary(isLiquid: true))
            
            Spacer()
            
            Color.clear.frame(width: 70, height: 32)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
    
    private var currencyHorizontalStrip: some View {
        let baseCurrencies = currencyViewModel.currencies
        let marqueeList = baseCurrencies + baseCurrencies + baseCurrencies
        
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(marqueeList.enumerated()), id: \.offset) { index, item in
                        let isSelected = item.id == tradeViewModel.selectedCurrency.id
                        
                        Button {
                            autoScrollIndex = index
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                tradeViewModel.selectCurrency(item)
                                proxy.scrollTo(index, anchor: .center)
                            }
                        } label: {
                            currencyItemView(item: item, isSelected: isSelected)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
            }
            .simultaneousGesture(
                DragGesture(coordinateSpace: .local)
                    .onChanged { _ in
                        isUserInteracting = true
                        interactionTimer?.cancel()
                    }
                    .onEnded { _ in
                        interactionTimer = Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            if !Task.isCancelled {
                                isUserInteracting = false
                            }
                        }
                    }
            )
            .onReceive(autoScrollPublisher) { _ in
                guard !isUserInteracting, !baseCurrencies.isEmpty else { return }
                
                let originalCount = baseCurrencies.count
                if autoScrollIndex >= originalCount * 2 {
                    autoScrollIndex = originalCount
                    proxy.scrollTo(autoScrollIndex, anchor: .center)
                }
                
                autoScrollIndex += 1
                withAnimation(.easeInOut(duration: 0.8)) {
                    proxy.scrollTo(autoScrollIndex, anchor: .center)
                }
            }
            .onAppear {
                let middleIndex = baseCurrencies.count
                autoScrollIndex = middleIndex
                proxy.scrollTo(middleIndex, anchor: .center)
            }
        }
        .frame(height: 75)
    }
    
    // MARK: - Ticker Card Design
    @ViewBuilder
    private func currencyItemView(item: Currency, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.flagEmoji)
                Text(item.id)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(getTextColor(isSelected: isSelected))
                Spacer()
                
                Image(systemName: item.changePercent > 0 ? "arrow.up.right.square.fill" : (item.changePercent < 0 ? "arrow.down.right.square.fill" : "minus.square.fill"))
                    .foregroundColor(getArrowColor(item: item, isLeftOrSelected: isSelected))
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Alış")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                    Text(String(format: "%.3f", item.buyRate))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? getTextColor(isSelected: isSelected) : .green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Satış")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                    Text(String(format: "%.3f", item.sellRate))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? getTextColor(isSelected: isSelected) : .red)
                }
            }
        }
        .frame(width: 140)
        .padding(12)
        .background(getTickerBackground(isSelected: isSelected))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.cyan.opacity(0.8) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: getShadowColor(isSelected: isSelected), radius: isSelected ? 6 : 2)
    }
    
    // MARK: - 3. Portfolio Summary (Wallet) Card
    private var portfolioSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Varlıklarım & Cüzdan Özeti")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                .padding(.bottom, 4)
            
            HStack {
                Image(systemName: "turkishlirasign.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Kullanılabilir Bakiye")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                Spacer()
                Text(String(format: "%.2f ₺", tradeViewModel.currentTLBalance))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
            }
            
            Divider().padding(.vertical, 4)
            

            ForEach(tradeViewModel.userHoldings.sorted(by: { $0.key < $1.key }), id: \.key) { holding in
                if holding.value > 0 { 
                    HStack {
                        Text(holding.key) 
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                        Spacer()
                        Text(String(format: "%.2f %@", holding.value, holding.key))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(16)
        .background(getCardBackground())
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.04), radius: 6)
    }
    
    private var balanceInfoCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Kullanılabilir TL")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                Text(String(format: "%.2f ₺", tradeViewModel.currentTLBalance))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
            }
            Spacer()
            Divider().frame(height: 30)
            VStack(alignment: .trailing, spacing: 4) {
                Text("Mevcut \(tradeViewModel.selectedCurrency.id) Varlığınız")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                Text(String(format: "%.2f %@", tradeViewModel.currentHolding, tradeViewModel.selectedCurrency.id))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isLiquidGlassEnabled ? .cyan : AppTheme.isCepAccent)
            }
        }
        .padding(16)
        .background(getCardBackground())
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.04), radius: 6)
    }
    
    private var rateInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Alış Fiyatı")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                Text(String(format: "%.4f ₺", tradeViewModel.selectedCurrency.buyRate))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Satış Fiyatı")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                Text(String(format: "%.4f ₺", tradeViewModel.selectedCurrency.sellRate))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(getCardBackground())
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.04), radius: 6)
    }
    
    private var amountInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("İşlem Miktarı (\(tradeViewModel.selectedCurrency.id))")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
            
            HStack {
                TextField("0.00", text: $tradeViewModel.amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                
                Text(tradeViewModel.selectedCurrency.id)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
            }
            .padding(12)
            .background(isLiquidGlassEnabled ? Color.white.opacity(0.08) : AppTheme.isCepBackgroundGray)
            .cornerRadius(12)
            
            HStack {
                Text("Tahmini TL Tutarı:")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                Spacer()
                Text(String(format: "%.2f ₺", tradeViewModel.estimatedTotalCost))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
            }
        }
        .padding(16)
        .background(getCardBackground())
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(isLiquidGlassEnabled ? 0.0 : 0.04), radius: 6)
    }
    
    private var tradeActionButtons: some View {
        HStack(spacing: 14) {
            Button {
                tradeViewModel.executeSell()
            } label: {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("SAT")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.red.opacity(0.85))
                .cornerRadius(14)
                .shadow(color: Color.red.opacity(0.3), radius: 5, y: 3)
            }
            
            Button {
                tradeViewModel.executeBuy()
            } label: {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("AL")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green.opacity(0.85))
                .cornerRadius(14)
                .shadow(color: Color.green.opacity(0.3), radius: 5, y: 3)
            }
        }
    }
    
    private func getCardBackground() -> Color {
        isLiquidGlassEnabled ? Color.white.opacity(0.12) : Color.white
    }
    
    private func getTickerBackground(isSelected: Bool) -> Color {
        if isSelected { return isLiquidGlassEnabled ? Color.white.opacity(0.3) : AppTheme.isCepNavy }
        return getCardBackground()
    }
    
    private func getTextColor(isSelected: Bool) -> Color {
        if isSelected { return isLiquidGlassEnabled ? .black : .white }
        return AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled)
    }
    
    private func getArrowColor(item: Currency, isLeftOrSelected: Bool) -> Color {
        if isLeftOrSelected { return isLiquidGlassEnabled ? .black : .white }
        if item.changePercent > 0 { return .green }
        if item.changePercent < 0 { return .red }
        return .gray
    }
    
    private func getShadowColor(isSelected: Bool) -> Color {
        return Color.black.opacity(isLiquidGlassEnabled ? 0.0 : (isSelected ? 0.15 : 0.04))
    }
}

#Preview {
    let dummyViewModel = CurrencyViewModel()
    let dummyCurrency = Currency(id: "USD", name: "Amerikan Doları", symbol: "$", flagEmoji: "🇺🇸", buyRate: 34.10, sellRate: 34.25, changePercent: 0.5)
    TradeDetailView(currencyViewModel: dummyViewModel, initialCurrency: dummyCurrency)
}
