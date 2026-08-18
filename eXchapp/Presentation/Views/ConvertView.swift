import SwiftUI

struct ConvertView: View {
    @StateObject private var viewModel = CurrencyViewModel()

    @State private var amountText: String = "100"
    @State private var fromID: String = "TRY"
    @State private var toID: String = "USD"

    private var allIDs: [String] { ["TRY"] + viewModel.currencies.map(\.id) }

    private var amount: Double { Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    private var result: Double { viewModel.convert(amount: amount, from: fromID, to: toID) }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0B4DB7"), Color(hex: "082870"), Color(hex: "04123A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        amountField

                        swapSelectors

                        resultCard

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(AppTheme.textPrimary)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Kur Çevirici")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Miktar")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            TextField("0", text: $amountText)
                .keyboardType(.decimalPad)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .convertTransparentCard(cornerRadius: 18)
    }

    private var swapSelectors: some View {
        HStack(spacing: 12) {
            currencyPicker(selection: $fromID)

            Button {
                swap(&fromID, &toID)
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(10)
                    .convertTransparentCard(cornerRadius: 12)
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
                    .foregroundColor(AppTheme.textPrimary)

                HStack {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.trailing, 14)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 48)
        }
        .convertTransparentCard(cornerRadius: 14)
    }

    private var resultCard: some View {
        VStack(spacing: 6) {
            Text("Sonuç")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            Text(String(format: "%.2f %@", result, toID))
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.yellow)
            Text("1 \(fromID) ≈ \(String(format: "%.4f", viewModel.convert(amount: 1, from: fromID, to: toID))) \(toID)")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .convertTransparentCard(cornerRadius: 18)
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
