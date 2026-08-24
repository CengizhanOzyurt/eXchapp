import SwiftUI

struct ConvertView: View {
    @AppStorage("liquidGlassEnabled") private var isLiquidGlassEnabled = false
    @StateObject private var viewModel = CurrencyViewModel()

    @State private var amountText: String = "100"
    @State private var fromID: String = "TRY"
    @State private var toID: String = "USD"

    private var allIDs: [String] { ["TRY"] + viewModel.currencies.map(\.id) }

    private var amount: Double { Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var result: Double { viewModel.convert(amount: amount, from: fromID, to: toID) }

    var body: some View {
        ZStack {
            AppTheme.background(isLiquid: isLiquidGlassEnabled)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Kur Çevirici")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.barForeground(isLiquid: isLiquidGlassEnabled))
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        amountField
                        swapSelectors
                        resultCard

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Miktar")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
            TextField("0", text: $amountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.textTertiary(isLiquid: isLiquidGlassEnabled))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .appCard(isLiquid: isLiquidGlassEnabled)
    }

    private var swapSelectors: some View {
        HStack(spacing: 12) {
            currencyPicker(selection: $fromID)

            Button {
                swap(&fromID, &toID)
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(AppTheme.textTertiary(isLiquid: isLiquidGlassEnabled))
                    .padding(10)
                    .appCard(isLiquid: isLiquidGlassEnabled)
            }

            currencyPicker(selection: $toID)
        }
    }

    private func currencyPicker(selection: Binding<String>) -> some View {
        Menu {
            ForEach(allIDs, id: \.self) { id in
                Button(id) { selection.wrappedValue = id }
            }
        } label: {
            ZStack {
                Text(selection.wrappedValue)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary(isLiquid: isLiquidGlassEnabled))

                HStack {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
                        .padding(.trailing, 14)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .appCard(isLiquid: isLiquidGlassEnabled)
    }

    private var resultCard: some View {
        VStack(spacing: 6) {
            Text("Sonuç")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
            Text(String(format: "%.2f %@", result, toID))
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.orange)
            Text("1 \(fromID) ≈ \(String(format: "%.4f", viewModel.convert(amount: 1, from: fromID, to: toID))) \(toID)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary(isLiquid: isLiquidGlassEnabled))
            
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .appCard(isLiquid: isLiquidGlassEnabled)
        
    }
}

private extension View {
    func convertTransparentCard(cornerRadius: CGFloat) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

#Preview {
    ConvertView()
}
