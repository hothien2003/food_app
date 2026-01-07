# HƯỚNG DẪN CÀI ĐẶT ỨNG DỤNG ĐẶT MÓN ĂN

## Yêu cầu hệ thống

### Backend (.NET Web API)
- .NET 6.0 SDK trở lên
- SQL Server 2019 trở lên
- Visual Studio 2022 hoặc VS Code

### Frontend (Flutter)
- Flutter SDK 3.0 trở lên
- Dart SDK 2.17 trở lên
- Android Studio / Xcode (cho mobile)
- Chrome (cho web)

## CÀI ĐẶT

### 1. Cài đặt Database

1. Mở SQL Server Management Studio
2. Tạo database mới có tên `FoodOrderDB`
3. Chạy script SQL từ file `Database/FoodOrderDB.sql`

```sql
-- Hoặc sử dụng câu lệnh
USE master;
GO
CREATE DATABASE FoodOrderDB;
GO
USE FoodOrderDB;
GO
-- Sau đó chạy script từ file FoodOrderDB.sql
```

### 2. Cài đặt Backend (Web API)

1. Mở folder `WebAPI` trong Visual Studio hoặc VS Code

2. Cấu hình connection string trong `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=FoodOrderDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

3. Chạy migrations (nếu cần):

```powershell
cd WebAPI\WebAPI
dotnet ef database update
```

4. Chạy API:

```powershell
dotnet run
```

API sẽ chạy tại: `https://localhost:7xxx` hoặc `http://localhost:5xxx`

### 3. Cài đặt Frontend (Flutter App)

1. Di chuyển vào folder Flutter:

```powershell
cd flutter_food_ordering_app\food_ordering_app
```

2. Cài đặt dependencies:

```powershell
flutter pub get
```

3. Cấu hình API endpoint trong file `lib/configs/api_config.dart` hoặc tương tự:

```dart
// Thay đổi base URL để trỏ đến API của bạn
const String baseUrl = "http://localhost:5xxx/api";
```

4. Chạy ứng dụng:

**Cho Android/iOS:**
```powershell
flutter run
```

**Cho Web:**
```powershell
flutter run -d chrome
```

**Cho Windows:**
```powershell
flutter run -d windows
```

## KIỂM TRA CÀI ĐẶT

### Test Backend
1. Mở trình duyệt và truy cập: `https://localhost:7xxx/swagger`
2. Kiểm tra các API endpoints có hoạt động không

### Test Frontend
1. Đảm bảo API đang chạy
2. Chạy app Flutter
3. Thử đăng nhập/đăng ký tài khoản
4. Kiểm tra các chức năng chính

## CẤU TRÚC DỰ ÁN

```
food_app/
├── Database/                 # SQL Scripts
├── WebAPI/                  # .NET Backend
│   └── WebAPI/
│       ├── Controllers/     # API Controllers
│       ├── Models/         # Data Models
│       ├── Migrations/     # EF Migrations
│       └── Images/         # Upload images
├── flutter_food_ordering_app/
│   └── food_ordering_app/  # Flutter App
│       ├── lib/
│       │   ├── api/        # API Services
│       │   ├── models/     # Data Models
│       │   ├── pages/      # App Pages
│       │   ├── screens/    # App Screens
│       │   ├── widgets/    # Reusable Widgets
│       │   └── main.dart   # Entry Point
│       └── assets/         # Images, Fonts
└── SoDoTienDo/             # Documentation
```

## TÍNH NĂNG CHÍNH

- **Người dùng:**
  - Đăng ký/Đăng nhập
  - Xem danh sách nhà hàng và món ăn
  - Thêm món vào giỏ hàng
  - Đặt hàng và thanh toán
  - Theo dõi đơn hàng
  - Đánh giá món ăn
  - Chat với nhà hàng
  - Quản lý thẻ tín dụng

- **Nhà hàng:**
  - Quản lý món ăn
  - Quản lý đơn hàng
  - Chat với khách hàng
  - Xem doanh thu

## GỠ LỖI THƯỜNG GẶP

### Backend không chạy được
- Kiểm tra SQL Server đã chạy chưa
- Kiểm tra connection string đúng chưa
- Chạy lại migrations: `dotnet ef database update`

### Flutter không build được
- Chạy: `flutter clean` và `flutter pub get`
- Kiểm tra Flutter SDK đã cài đặt đúng: `flutter doctor`
- Đảm bảo có thiết bị/emulator đang chạy

### Không kết nối được API
- Kiểm tra API đang chạy và accessible
- Với Android emulator: Dùng `10.0.2.2` thay vì `localhost`
- Với iOS simulator: Dùng `localhost` hoặc IP máy thực
- Kiểm tra firewall/antivirus

### Lỗi CORS (Cross-Origin)
- Thêm CORS configuration trong `Program.cs`:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder => builder
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
});

// Sau đó sử dụng:
app.UseCors("AllowAll");
```

## HỖ TRỢ

Nếu gặp vấn đề trong quá trình cài đặt, vui lòng:
1. Kiểm tra lại các bước cài đặt
2. Xem log lỗi chi tiết
3. Tham khảo tài liệu trong các file:
   - `NOTIFICATION_GUIDE.md` - Hướng dẫn thông báo
   - `NOTIFICATION_IMPLEMENTATION.md` - Triển khai thông báo
   - `PAYMENT_SYSTEM_GUIDE.md` - Hệ thống thanh toán

## LƯU Ý BẢO MẬT

- **KHÔNG** commit file chứa thông tin nhạy cảm (connection strings, API keys)
- Sử dụng environment variables cho production
- Thay đổi secret keys mặc định
- Bật HTTPS cho production
- Cập nhật packages thường xuyên

## TRIỂN KHAI (DEPLOYMENT)

### Backend
- Azure App Service
- AWS Elastic Beanstalk
- Docker Container

### Frontend
- Google Play Store (Android)
- Apple App Store (iOS)
- Web Hosting (cho Flutter Web)

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 25/12/2025  
**Tác giả:** Food Ordering App Team
