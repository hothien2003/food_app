# Hệ thống Thông báo - Hướng dẫn sử dụng

## Tổng quan
Hệ thống thông báo đã được tích hợp vào ứng dụng Food Ordering, cho phép người dùng nhận thông báo về các hoạt động như đặt hàng, thanh toán, đánh giá, v.v.

## Cấu trúc

### 1. Model (`models/Notification.dart`)
- **NotificationModel**: Class chính chứa thông tin thông báo
  - `id`: ID duy nhất
  - `title`: Tiêu đề thông báo
  - `message`: Nội dung chi tiết
  - `timestamp`: Thời gian tạo
  - `isRead`: Trạng thái đã đọc/chưa đọc
  - `type`: Loại thông báo (NotificationType)
  - `data`: Dữ liệu bổ sung (JSON)

- **NotificationType**: Enum định nghĩa các loại thông báo
  - `orderPlaced`: Đơn hàng đã đặt
  - `orderConfirmed`: Đơn hàng đã xác nhận
  - `orderPreparing`: Đang chuẩn bị
  - `orderPickedUp`: Tài xế đã lấy món
  - `orderDelivered`: Đã giao hàng
  - `orderCancelled`: Đơn hàng bị hủy
  - `paymentSuccess`: Thanh toán thành công
  - `paymentFailed`: Thanh toán thất bại
  - `refund`: Hoàn tiền
  - `review`: Đánh giá
  - `promotion`: Khuyến mãi
  - `reward`: Điểm thưởng
  - `general`: Thông báo chung

### 2. Service (`services/notification_service.dart`)
**NotificationService** - Singleton service quản lý thông báo

#### Phương thức chính:
- `init()`: Khởi tạo và load thông báo từ SharedPreferences
- `addNotification()`: Thêm thông báo mới
- `getAllNotifications()`: Lấy tất cả thông báo
- `getUnreadNotifications()`: Lấy thông báo chưa đọc
- `getUnreadCount()`: Đếm số thông báo chưa đọc
- `markAsRead(id)`: Đánh dấu đã đọc
- `markAllAsRead()`: Đánh dấu tất cả đã đọc
- `deleteNotification(id)`: Xóa thông báo
- `clearAllNotifications()`: Xóa tất cả

#### Phương thức tiện lợi:
- `notifyOrderPlaced(orderId, restaurantName)`: Thông báo đặt hàng thành công
- `notifyOrderConfirmed(orderId)`: Thông báo đơn hàng được xác nhận
- `notifyOrderPreparing(orderId)`: Thông báo đang chuẩn bị
- `notifyOrderPickedUp(orderId)`: Thông báo tài xế đã lấy
- `notifyOrderDelivered(orderId)`: Thông báo đã giao
- `notifyOrderCancelled(orderId, reason)`: Thông báo hủy đơn
- `notifyPaymentSuccess(orderId, amount)`: Thông báo thanh toán thành công
- `notifyPaymentFailed(orderId)`: Thông báo thanh toán thất bại
- `notifyRefund(orderId, amount)`: Thông báo hoàn tiền
- `notifyReviewSubmitted(restaurantName)`: Thông báo đánh giá đã gửi
- `notifyPromotion(title, message)`: Thông báo khuyến mãi
- `notifyReward(points)`: Thông báo điểm thưởng

### 3. UI Components

#### NotificationScreen (`screens/notificationScreen.dart`)
- Hiển thị danh sách thông báo
- Hỗ trợ vuốt để xóa (swipe to delete)
- Nút đánh dấu tất cả đã đọc
- Hiển thị icon theo loại thông báo
- Màu sắc khác nhau cho đã đọc/chưa đọc

#### MoreScreen (`screens/moreScreen.dart`)
- Hiển thị badge số thông báo chưa đọc
- Tự động cập nhật sau khi quay lại từ NotificationScreen

## Cách sử dụng

### 1. Thêm thông báo khi đặt hàng thành công
```dart
import 'package:food_ordering_app/services/notification_service.dart';

// Sau khi đặt hàng thành công
await NotificationService.instance.notifyOrderPlaced(
  orderId, 
  restaurantName
);

// Thông báo thanh toán
await NotificationService.instance.notifyPaymentSuccess(
  orderId, 
  totalAmount
);
```

### 2. Thêm thông báo khi đánh giá
```dart
await NotificationService.instance.notifyReviewSubmitted(
  restaurantName
);
```

### 3. Thêm thông báo khuyến mãi
```dart
await NotificationService.instance.notifyPromotion(
  'Giảm giá 50%',
  'Giảm giá 50% cho đơn hàng đầu tiên trong tháng'
);
```

### 4. Thêm thông báo tùy chỉnh
```dart
await NotificationService.instance.addNotification(
  title: 'Tiêu đề',
  message: 'Nội dung thông báo',
  type: NotificationType.general,
  data: {'customKey': 'customValue'},
);
```

### 5. Kiểm tra số thông báo chưa đọc
```dart
final unreadCount = NotificationService.instance.getUnreadCount();
```

### 6. Đánh dấu đã đọc
```dart
// Đánh dấu một thông báo
await NotificationService.instance.markAsRead(notificationId);

// Đánh dấu tất cả
await NotificationService.instance.markAllAsRead();
```

## Tích hợp vào các màn hình khác

### Ví dụ: Thêm vào màn hình đánh giá
```dart
// Trong file review_screen.dart hoặc tương tự
import 'package:food_ordering_app/services/notification_service.dart';

// Sau khi submit đánh giá thành công
await NotificationService.instance.notifyReviewSubmitted(
  widget.restaurantName
);
```

### Ví dụ: Thêm vào giỏ hàng
```dart
// Khi thêm món vào giỏ hàng
await NotificationService.instance.addNotification(
  title: 'Đã thêm vào giỏ hàng',
  message: '${dishName} đã được thêm vào giỏ hàng',
  type: NotificationType.general,
);
```

### Ví dụ: Cập nhật trạng thái đơn hàng (từ backend)
```dart
// Khi nhận được update từ API về trạng thái đơn hàng
switch (orderStatus) {
  case 'confirmed':
    await NotificationService.instance.notifyOrderConfirmed(orderId);
    break;
  case 'preparing':
    await NotificationService.instance.notifyOrderPreparing(orderId);
    break;
  case 'picked_up':
    await NotificationService.instance.notifyOrderPickedUp(orderId);
    break;
  case 'delivered':
    await NotificationService.instance.notifyOrderDelivered(orderId);
    break;
  case 'cancelled':
    await NotificationService.instance.notifyOrderCancelled(
      orderId, 
      cancellationReason
    );
    break;
}
```

## Tính năng

✅ Lưu trữ thông báo local với SharedPreferences
✅ Hiển thị thời gian thân thiện (vừa xong, 5 phút trước, v.v.)
✅ Badge hiển thị số thông báo chưa đọc
✅ Vuốt để xóa thông báo
✅ Đánh dấu đã đọc/chưa đọc
✅ Icon và màu sắc khác nhau theo loại thông báo
✅ Giới hạn 100 thông báo gần nhất
✅ Hỗ trợ đa ngôn ngữ (Việt/Anh)

## Lưu ý
- Thông báo được lưu trong SharedPreferences, không cần database
- Tự động sắp xếp theo thời gian mới nhất
- Giới hạn 100 thông báo để tránh tràn bộ nhớ
- Service sử dụng Singleton pattern để đảm bảo consistency

## Mở rộng trong tương lai
1. Push notification từ Firebase
2. Notification scheduling (lên lịch thông báo)
3. Notification với hình ảnh
4. Action buttons trong thông báo
5. Group notifications theo loại
6. Sound/vibration cho thông báo mới
