# AUTILEARN
## Ứng dụng dạy học cho trẻ tự kỷ

---

## Giới thiệu dự án

- **Tên dự án**: AutiLearn
- **Mục tiêu**: Hỗ trợ dạy học cho trẻ tự kỷ thông qua các thẻ học trực quan và trò chơi đơn giản
- **Đối tượng người dùng**: 
  - Trẻ tự kỷ (học sinh)
  - Giáo viên
  - Phụ huynh

---

## Vấn đề và giải pháp

### Vấn đề
- Trẻ tự kỷ gặp khó khăn trong việc học tập theo phương pháp truyền thống
- Thiếu công cụ học tập trực quan, tương tác phù hợp với trẻ tự kỷ
- Khó khăn trong việc theo dõi tiến độ học tập của trẻ

### Giải pháp
- Ứng dụng học tập trực quan với giao diện thân thiện
- Đa dạng bài tập tương tác phù hợp với trẻ tự kỷ
- Hệ thống theo dõi tiến độ và phân tích dữ liệu học tập

---

## Công nghệ sử dụng

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Storage
- **Kiến trúc**: Clean Architecture với BLoC pattern
- **Thư viện chính**:
  - flutter_bloc
  - dartz
  - get_it
  - equatable
  - cloud_firestore

---

## Các vai trò người dùng

### 👶 Học sinh (Trẻ tự kỷ)
- Học tập qua thẻ học trực quan
- Tham gia trò chơi học tập đơn giản
- Nhận phần thưởng và huy hiệu

### 👩‍🏫 Giáo viên
- Tạo và quản lý nội dung học tập
- Theo dõi tiến độ học tập của học sinh
- Điều chỉnh chương trình học phù hợp

### 👨‍👩‍👧 Phụ huynh
- Xem báo cáo học tập của con
- Nhận gợi ý hoạt động học tại nhà
- Tạo bài học bổ sung

---

## Tính năng chính

1. **Hệ thống xác thực người dùng**
   - Đăng ký, đăng nhập, quên mật khẩu
   - Phân quyền theo vai trò

2. **Các loại bài tập học tập**
   - Bài học lựa chọn
   - Bài học ghép đôi
   - Bài học sắp xếp
   - Nhận diện cảm xúc
   - Học vẽ

3. **Hệ thống theo dõi tiến độ**
   - Báo cáo chi tiết kết quả học tập
   - Biểu đồ phân tích tiến bộ
   - Thống kê thời gian học tập

4. **Hệ thống phần thưởng**
   - Huy hiệu thành tích
   - Phần thưởng ảo
   - Cửa hàng đổi thưởng

5. **Tính năng vẽ**
   - Vẽ tự do
   - Tô màu theo mẫu

---

## Kiến trúc ứng dụng

### Clean Architecture
- **Presentation Layer**: UI, BLoC
- **Domain Layer**: Use Cases, Entities
- **Data Layer**: Repositories, Data Sources

### BLoC Pattern
- Quản lý trạng thái ứng dụng
- Tách biệt logic nghiệp vụ và UI
- Dễ dàng kiểm thử

---

## Cơ sở dữ liệu

### Collections chính
- users
- quizzes
- questions
- user_progress
- badges
- rewards
- drawing_templates
- drawings
- analytics

---

## Demo ứng dụng

### Luồng demo
1. Đăng nhập với vai trò giáo viên
2. Tạo bài học mới
3. Đăng nhập với vai trò học sinh
4. Thực hiện bài học
5. Xem tiến độ học tập
6. Sử dụng tính năng vẽ

---

## Kết luận và hướng phát triển

### Kết quả đạt được
- Ứng dụng học tập trực quan cho trẻ tự kỷ
- Hệ thống theo dõi tiến độ chi tiết
- Đa dạng loại bài tập và phương pháp học

### Hướng phát triển tương lai
- Tích hợp AI để cá nhân hóa việc học
- Mở rộng thêm loại bài tập
- Phát triển tính năng cộng đồng cho phụ huynh và giáo viên
- Hỗ trợ đa ngôn ngữ

---

## Cảm ơn!

### Thông tin liên hệ
- Email: [your-email@example.com]
- GitHub: [your-github-username]
