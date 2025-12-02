# 💳 Hệ thống Thanh toán - Hướng dẫn Sử dụng

## 🎯 Tổng quan

Hệ thống thanh toán đa phương thức đã được tích hợp hoàn chỉnh vào ứng dụng Food Ordering App với **5 phương thức thanh toán**:

1. ✅ **COD** - Tiền mặt khi nhận hàng
2. ✅ **MoMo** - Ví điện tử MoMo (Mock)
3. ✅ **ZaloPay** - Ví điện tử ZaloPay (Mock)
4. ✅ **Thẻ tín dụng/Ghi nợ** - Visa, Mastercard, JCB (Mock với validation thật)
5. ✅ **Chuyển khoản QR** - QR Code ngân hàng theo chuẩn VietQR

---

## 📁 Cấu trúc File

### Models
```
lib/models/Payment.dart
├── PaymentMethodType (enum)
├── PaymentMethod (class)
├── PaymentStatus (enum)
├── PaymentResult (class)
└── CardInfo (class) + validation helpers
```

### Services
```
lib/services/payment_service.dart
- Singleton service xử lý tất cả payment logic
- Mock payment processing với delay thực tế
- Test cards support
- VietQR generation
```

### Screens
```
lib/screens/
├── card_payment_screen.dart       - Form nhập thẻ + validation
├── ewallet_payment_screen.dart    - MoMo/ZaloPay QR payment
├── qr_banking_payment_screen.dart - QR chuyển khoản + countdown
└── payment_result_screen.dart     - Kết quả success/failed
```

### Integration
```
lib/pages/ThanhToan/thanhtoan_page.dart
- Đã tích hợp tất cả 5 phương thức thanh toán
- Navigate đến màn hình phù hợp theo method
```

---

## 🚀 Cách sử dụng

### 1️⃣ **COD (Cash on Delivery)**
```dart
// Flow: Chọn COD → Đặt hàng → Luôn thành công
// Không cần màn hình bổ sung
```

**Đặc điểm:**
- ✅ Thanh toán khi nhận hàng
- ✅ Luôn thành công 100%
- ✅ Không cần xử lý thêm

---

### 2️⃣ **MoMo / ZaloPay**
```dart
// Flow: Chọn ví → Màn hình QR → Loading 3s → Kết quả
```

**Màn hình:** `EWalletPaymentScreen`

**Tính năng:**
- ✅ Hiển thị QR code mock
- ✅ Logo và branding theo ví
- ✅ Giả lập delay 3 giây
- ✅ Success rate: 85%
- ✅ Auto-process sau 2 giây

**Test:**
- Chọn MoMo/ZaloPay
- Xem QR code
- Đợi 3 giây
- 85% thành công, 15% thất bại

---

### 3️⃣ **Chuyển khoản QR (Banking)**
```dart
// Flow: Chọn QR → QR Screen → Copy info → Confirm → Loading 5s → Kết quả
```

**Màn hình:** `QRBankingPaymentScreen`

**Tính năng:**
- ✅ QR Code theo chuẩn VietQR
- ✅ Countdown timer 5 phút
- ✅ Copy thông tin CK
- ✅ Hướng dẫn từng bước
- ✅ Success rate: 90%

**Thông tin CK:**
```
Ngân hàng: MB Bank
Số TK: 0123456789
Nội dung: FD{orderId}
Số tiền: {amount}
```

**Test:**
- Chọn "Chuyển khoản QR"
- Xem QR code + thông tin
- Nhấn "Đã chuyển khoản"
- Đợi 5 giây
- 90% thành công

---

### 4️⃣ **Thẻ tín dụng/Ghi nợ**
```dart
// Flow: Chọn thẻ → Form nhập → Validate → Loading 4s → Kết quả
```

**Màn hình:** `CardPaymentScreen`

**Tính năng:**
- ✅ Form validation thật (Luhn algorithm)
- ✅ Format tự động số thẻ
- ✅ Validate expiry date
- ✅ Validate CVV
- ✅ Detect card type (Visa, Mastercard, etc.)
- ✅ Test cards support

**Test Cards:**

| Số thẻ | Kết quả |
|--------|---------|
| 4242 4242 4242 4242 | ✅ Luôn thành công |
| 4000 0000 0000 0002 | ❌ Luôn thất bại |
| Số khác (valid) | 🎲 Random 80% success |

**Validation Rules:**
- Số thẻ: 13-19 chữ số, Luhn algorithm
- Expiry: MM/YY format, không quá hạn
- CVV: 3-4 chữ số
- Tên: Bắt buộc

**Test:**
```
Thẻ thành công:
Card Number: 4242 4242 4242 4242
Name: NGUYEN VAN A
Expiry: 12/25
CVV: 123

Thẻ thất bại:
Card Number: 4000 0000 0000 0002
Name: TEST FAIL
Expiry: 12/25
CVV: 123
```

---

## 🎨 Màn hình Kết quả

**PaymentResultScreen** hiển thị cho tất cả phương thức:

**Thành công ✅:**
- Icon check xanh lá
- Thông tin giao dịch đầy đủ
- Nút "Xem đơn hàng"

**Thất bại ❌:**
- Icon lỗi đỏ
- Lý do thất bại
- Nút "Thử lại" + "Về trang chủ"

**Thông tin hiển thị:**
- Số tiền
- Phương thức thanh toán
- Mã giao dịch
- Thời gian
- Metadata (loại thẻ, ví, ngân hàng, v.v.)

---

## 🧪 Testing Guide

### Test Flow Đầy đủ:

**1. Test COD:**
```
1. Chọn phương thức "Tiền mặt (COD)"
2. Nhấn "Đặt hàng"
3. ✅ Luôn thành công
```

**2. Test MoMo:**
```
1. Chọn phương thức "Ví MoMo"
2. Nhấn "Đặt hàng"
3. Xem màn hình MoMo với QR
4. Đợi 3 giây
5. ✅ 85% thành công
```

**3. Test ZaloPay:**
```
1. Chọn phương thức "ZaloPay"
2. Nhấn "Đặt hàng"
3. Xem màn hình ZaloPay với QR
4. Đợi 3 giây
5. ✅ 85% thành công
```

**4. Test QR Banking:**
```
1. Chọn phương thức "Chuyển khoản QR"
2. Nhấn "Đặt hàng"
3. Xem QR code + countdown timer
4. Copy thông tin chuyển khoản
5. Nhấn "Đã chuyển khoản"
6. Đợi 5 giây
7. ✅ 90% thành công
```

**5. Test Card - Success:**
```
1. Chọn phương thức "Thẻ tín dụng/Ghi nợ"
2. Nhấn "Đặt hàng"
3. Nhập:
   - Card: 4242 4242 4242 4242
   - Name: NGUYEN VAN A
   - Expiry: 12/25
   - CVV: 123
4. Nhấn "Thanh toán"
5. Đợi 4 giây
6. ✅ Luôn thành công
```

**6. Test Card - Decline:**
```
1. Chọn phương thức "Thẻ tín dụng/Ghi nợ"
2. Nhập:
   - Card: 4000 0000 0000 0002
   - Name: TEST FAIL
   - Expiry: 12/25
   - CVV: 123
3. Nhấn "Thanh toán"
4. Đợi 4 giây
5. ❌ Luôn thất bại
```

**7. Test Card - Validation:**
```
1. Thử nhập số thẻ không hợp lệ
2. ❌ Hiển thị lỗi "Số thẻ không hợp lệ"

3. Thử nhập expiry quá hạn (01/20)
4. ❌ Hiển thị lỗi "Thẻ đã hết hạn"

5. Thử nhập CVV < 3 số
6. ❌ Hiển thị lỗi "CVV không hợp lệ"
```

---

## 📊 Success Rates

| Phương thức | Success Rate | Delay |
|-------------|--------------|-------|
| COD | 100% | Instant |
| MoMo | 85% | 3 giây |
| ZaloPay | 85% | 3 giây |
| Banking QR | 90% | 5 giây |
| Card (Test Success) | 100% | 4 giây |
| Card (Test Fail) | 0% | 4 giây |
| Card (Random) | 80% | 4 giây |

---

## 🔔 Tích hợp Thông báo

Tất cả thanh toán đều tự động tạo thông báo:

**Thành công:**
```dart
NotificationService.instance.notifyPaymentSuccess(orderId, amount);
```

**Thất bại:**
```dart
NotificationService.instance.notifyPaymentFailed(orderId);
```

Xem thông báo tại: **More → Thông báo**

---

## 🛠️ API Reference

### PaymentService

```dart
// Singleton instance
final paymentService = PaymentService.instance;

// Process payment
PaymentResult result = await paymentService.processPayment(
  method: PaymentMethodType.momo,
  orderId: 12345,
  amount: 150000,
  cardInfo: cardInfo, // Optional, chỉ cho card payment
);

// Generate VietQR data
String qrData = paymentService.generateVietQRData(
  orderId: 12345,
  amount: 150000,
);

// Format card number
String formatted = paymentService.formatCardNumber('4242424242424242');
// Output: "4242 4242 4242 4242"

// Format expiry date
String formatted = paymentService.formatExpiryDate('1225');
// Output: "12/25"
```

### CardInfo Validation

```dart
// Validate card number (Luhn algorithm)
bool isValid = CardInfo.validateCardNumber('4242424242424242');

// Validate expiry date
bool isValid = CardInfo.validateExpiryDate('12/25');

// Validate CVV
bool isValid = CardInfo.validateCVV('123');

// Get card type
String type = CardInfo.getCardType('4242424242424242');
// Output: "Visa"
```

---

## 📱 Screenshots Flow

```
ThanhToanPage
    ↓
[Chọn phương thức thanh toán]
    ↓
┌─────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│    COD      │    MoMo      │   ZaloPay    │   Banking    │     Card     │
└─────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
      ↓              ↓               ↓              ↓              ↓
   Success    EWalletScreen   EWalletScreen  QRBankingScreen CardPaymentScreen
                    ↓               ↓              ↓              ↓
              Loading 3s      Loading 3s    Countdown 5m    Validate + Loading
                    ↓               ↓              ↓              ↓
            PaymentResultScreen (Success/Failed cho tất cả)
                    ↓
            [Xem đơn hàng] hoặc [Thử lại/Về trang chủ]
```

---

## ⚙️ Dependencies

Đảm bảo đã thêm vào `pubspec.yaml`:

```yaml
dependencies:
  qr_flutter: ^4.1.0  # Tạo QR code
  intl: ^0.18.0       # Format số tiền
```

Chạy:
```bash
flutter pub get
```

---

## 🎯 Tính năng

### ✅ Đã hoàn thành:
- [x] 5 phương thức thanh toán
- [x] Mock payment processing
- [x] Real validation cho card
- [x] QR code generation
- [x] Countdown timer
- [x] Success/Failure handling
- [x] Payment result screen
- [x] Notification integration
- [x] Test cards support
- [x] Auto-formatting inputs
- [x] Error handling
- [x] Loading states
- [x] Beautiful UI/UX

### 🚀 Có thể mở rộng:
- [ ] VNPay Sandbox integration (real payment test)
- [ ] Stripe integration
- [ ] Lưu thẻ cho lần sau
- [ ] Payment history
- [ ] Receipt/Invoice PDF
- [ ] 3D Secure authentication
- [ ] Installment payment
- [ ] Voucher/Discount codes

---

## 💡 Tips & Best Practices

1. **Test Cards:** Luôn dùng test cards để demo
2. **Validation:** Frontend validation đã đầy đủ
3. **UX:** Loading states và animations mượt mà
4. **Error Handling:** Tất cả errors đều được catch
5. **Notifications:** Tự động tạo thông báo
6. **Navigation:** Proper back navigation handling

---

## 🐛 Troubleshooting

**Q: QR code không hiển thị?**
- A: Đảm bảo đã cài `qr_flutter` package

**Q: Validation thẻ không hoạt động?**
- A: Kiểm tra đã import đúng `CardInfo` class

**Q: Payment luôn thất bại?**
- A: Kiểm tra success rate trong code, có thể adjust

**Q: Không navigate được?**
- A: Đảm bảo context còn mounted trước khi navigate

---

## 📝 Notes

- **Miễn phí 100%:** Tất cả đều mock, không tốn phí
- **Production Ready:** UI/UX sẵn sàng cho production
- **Easy to integrate:** Chỉ cần thay mock bằng real API
- **Well documented:** Code có comments đầy đủ

---

## 🎊 Kết luận

Hệ thống thanh toán đã hoàn chỉnh với:
- ✅ 5 phương thức thanh toán
- ✅ Full validation
- ✅ Beautiful UI
- ✅ Mock processing
- ✅ Notification integration
- ✅ Error handling
- ✅ Test cards support

**Sẵn sàng demo!** 🚀

---

**Phát triển bởi:** GitHub Copilot  
**Ngày hoàn thành:** 26/11/2025  
**Version:** 1.0.0
