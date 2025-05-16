# Cấu trúc cơ sở dữ liệu AutiLearn

AutiLearn sử dụng Firebase Firestore làm cơ sở dữ liệu chính. Dưới đây là chi tiết về các collections và cấu trúc dữ liệu.

## Collections chính

### 1. users
Lưu trữ thông tin người dùng.

```javascript
{
  id: string,                // ID người dùng (từ Firebase Auth)
  name: string,              // Tên người dùng
  email: string,             // Email
  role: string,              // Vai trò: 'student', 'teacher', 'parent'
  avatarUrl: string,         // URL ảnh đại diện
  currentBadgeId: string,    // ID huy hiệu hiện tại
  createdAt: timestamp,      // Thời gian tạo tài khoản
  updatedAt: timestamp       // Thời gian cập nhật gần nhất
}
```

### 2. quizzes
Lưu trữ thông tin về các bài kiểm tra/bài học.

```javascript
{
  id: string,                // ID bài kiểm tra
  title: string,             // Tiêu đề
  description: string,       // Mô tả
  type: string,              // Loại: 'choices_quiz', 'pairing_quiz', 'sequential_quiz', 'emotions_quiz'
  category: string,          // Danh mục: 'Toán học', 'Ngôn ngữ', 'Kỹ năng xã hội'...
  difficulty: string,        // Độ khó: 'easy', 'medium', 'hard'
  creatorId: string,         // ID người tạo
  isPublished: boolean,      // Đã xuất bản chưa
  questionCount: number,     // Số lượng câu hỏi
  ageRangeMin: number,       // Độ tuổi tối thiểu
  ageRangeMax: number,       // Độ tuổi tối đa
  imageUrl: string,          // URL hình ảnh đại diện
  tags: array,               // Các thẻ liên quan
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 3. questions
Lưu trữ các câu hỏi cho bài kiểm tra.

```javascript
{
  id: string,                // ID câu hỏi
  quizId: string,            // ID bài kiểm tra
  text: string,              // Nội dung câu hỏi
  type: string,              // Loại câu hỏi: 'choices', 'pairing', 'sequential', 'emotions'
  options: array,            // Các lựa chọn
  /*
    options: [
      {
        id: string,          // ID lựa chọn
        text: string,        // Nội dung
        imageUrl: string     // URL hình ảnh (nếu có)
      }
    ]
  */
  correctOptionId: string,   // ID lựa chọn đúng (cho choices_quiz)
  correctPairs: object,      // Các cặp đúng (cho pairing_quiz)
  correctOrder: array,       // Thứ tự đúng (cho sequential_quiz)
  hint: string,              // Gợi ý
  explanation: string,       // Giải thích
  order: number,             // Thứ tự câu hỏi
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 4. user_progress
Lưu trữ tiến độ học tập của người dùng.

```javascript
{
  id: string,                // ID tiến độ
  userId: string,            // ID người dùng
  quizId: string,            // ID bài kiểm tra
  score: number,             // Điểm số
  isCompleted: boolean,      // Đã hoàn thành chưa
  startedAt: timestamp,      // Thời gian bắt đầu
  completedAt: timestamp,    // Thời gian hoàn thành
  answers: object,           // Câu trả lời của người dùng
  totalQuestions: number,    // Tổng số câu hỏi
  attempts: array,           // Các lần thử
  /*
    attempts: [
      {
        questionId: string,  // ID câu hỏi
        answerId: string,    // ID câu trả lời
        isCorrect: boolean,  // Đúng hay sai
        timeSpent: number    // Thời gian trả lời (giây)
      }
    ]
  */
  timeSpentSeconds: number,  // Tổng thời gian làm bài (giây)
  starsEarned: number        // Số sao nhận được
}
```

### 5. badges
Lưu trữ thông tin về các huy hiệu.

```javascript
{
  id: string,                // ID huy hiệu
  name: string,              // Tên huy hiệu
  description: string,       // Mô tả
  imageUrl: string,          // URL hình ảnh
  category: string,          // Danh mục: 'completion', 'streak', 'mastery', 'special'
  requiredPoints: number,    // Điểm cần thiết để đạt được
  isDefault: boolean,        // Có phải huy hiệu mặc định không
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 6. user_badges
Lưu trữ huy hiệu của người dùng (subcollection của users).

```javascript
{
  id: string,                // ID huy hiệu người dùng
  badgeId: string,           // ID huy hiệu
  isUnlocked: boolean,       // Đã mở khóa chưa
  unlockedAt: timestamp,     // Thời gian mở khóa
  progress: number           // Tiến độ đạt được (0-100%)
}
```

### 7. rewards
Lưu trữ thông tin về các phần thưởng.

```javascript
{
  id: string,                // ID phần thưởng
  name: string,              // Tên phần thưởng
  description: string,       // Mô tả
  imageUrl: string,          // URL hình ảnh
  type: string,              // Loại: 'avatar', 'background', 'character', 'accessory', 'theme'
  cost: number,              // Giá (số sao cần thiết)
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 8. user_rewards
Lưu trữ phần thưởng của người dùng (subcollection của users).

```javascript
{
  id: string,                // ID phần thưởng người dùng
  rewardId: string,          // ID phần thưởng
  isPurchased: boolean,      // Đã mua chưa
  purchasedAt: timestamp,    // Thời gian mua
  isEquipped: boolean        // Đang sử dụng
}
```

### 9. currency
Lưu trữ thông tin về tiền tệ ảo của người dùng.

```javascript
{
  id: string,                // ID người dùng
  stars: number,             // Số sao
  coins: number,             // Số xu
  lastUpdated: timestamp     // Thời gian cập nhật gần nhất
}
```

### 10. drawing_templates
Lưu trữ các mẫu vẽ.

```javascript
{
  id: string,                // ID mẫu vẽ
  title: string,             // Tiêu đề
  description: string,       // Mô tả
  imageUrl: string,          // URL hình ảnh mẫu
  category: string,          // Danh mục: 'animals', 'nature', 'objects'
  difficulty: string,        // Độ khó: 'easy', 'medium', 'hard'
  creatorId: string,         // ID người tạo
  isPublished: boolean,      // Đã xuất bản chưa
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 11. drawings
Lưu trữ các bản vẽ của người dùng.

```javascript
{
  id: string,                // ID bản vẽ
  userId: string,            // ID người dùng
  title: string,             // Tiêu đề
  imageUrl: string,          // URL hình ảnh bản vẽ
  templateId: string,        // ID mẫu vẽ (nếu có)
  type: string,              // Loại: 'free_drawing', 'template_drawing'
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 12. analytics
Lưu trữ phân tích dữ liệu học tập của người dùng.

```javascript
{
  userId: string,            // ID người dùng
  totalQuizzesTaken: number, // Tổng số bài kiểm tra đã làm
  totalCorrectAnswers: number, // Tổng số câu trả lời đúng
  totalQuestions: number,    // Tổng số câu hỏi đã làm
  totalTimeSpentSeconds: number, // Tổng thời gian học tập (giây)
  totalStarsEarned: number,  // Tổng số sao đã kiếm được
  quizTypeDistribution: object, // Phân bố theo loại bài kiểm tra
  /*
    quizTypeDistribution: {
      'choices_quiz': 10,
      'pairing_quiz': 5,
      'sequential_quiz': 3,
      'emotions_quiz': 2
    }
  */
  performanceByQuizType: object, // Hiệu suất theo loại bài kiểm tra
  /*
    performanceByQuizType: {
      'choices_quiz': 0.85,  // 85% đúng
      'pairing_quiz': 0.75,
      'sequential_quiz': 0.9,
      'emotions_quiz': 0.8
    }
  */
  recentPerformance: array,  // Hiệu suất gần đây
  /*
    recentPerformance: [
      {
        quizId: string,      // ID bài kiểm tra
        quizTitle: string,   // Tiêu đề bài kiểm tra
        score: number,       // Điểm số
        totalQuestions: number, // Tổng số câu hỏi
        completedAt: timestamp // Thời gian hoàn thành
      }
    ]
  */
  lastUpdated: timestamp     // Thời gian cập nhật gần nhất
}
```

### 13. teacher_student_links
Lưu trữ liên kết giữa giáo viên và học sinh.

```javascript
{
  id: string,                // ID liên kết
  teacherId: string,         // ID giáo viên
  studentId: string,         // ID học sinh
  status: string,            // Trạng thái: 'pending', 'accepted', 'rejected'
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 14. skill_assessments
Lưu trữ đánh giá kỹ năng của học sinh.

```javascript
{
  id: string,                // ID đánh giá
  studentId: string,         // ID học sinh
  teacherId: string,         // ID giáo viên đánh giá
  date: timestamp,           // Ngày đánh giá
  skills: array,             // Các kỹ năng được đánh giá
  /*
    skills: [
      {
        name: string,        // Tên kỹ năng
        category: string,    // Danh mục: 'communication', 'social', 'motor', 'cognitive'
        rating: number,      // Đánh giá (1-5)
        notes: string        // Ghi chú
      }
    ]
  */
  notes: string,             // Ghi chú chung
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

### 15. schedules
Lưu trữ lịch học của học sinh.

```javascript
{
  id: string,                // ID lịch học
  studentId: string,         // ID học sinh
  teacherId: string,         // ID giáo viên
  title: string,             // Tiêu đề
  description: string,       // Mô tả
  startTime: timestamp,      // Thời gian bắt đầu
  endTime: timestamp,        // Thời gian kết thúc
  isRecurring: boolean,      // Có lặp lại không
  recurrencePattern: string, // Mẫu lặp lại: 'daily', 'weekly', 'monthly'
  recurrenceDays: array,     // Các ngày lặp lại (cho weekly)
  notificationTime: number,  // Thời gian thông báo trước (phút)
  createdAt: timestamp,      // Thời gian tạo
  updatedAt: timestamp       // Thời gian cập nhật
}
```

## Indexes

Để tối ưu hiệu suất truy vấn, cần tạo các indexes sau:

### Composite Indexes

1. **quizzes**
   - `type` ASC, `isPublished` ASC, `createdAt` DESC

2. **questions**
   - `quizId` ASC, `order` ASC

3. **user_progress**
   - `userId` ASC, `completedAt` DESC
   - `userId` ASC, `quizId` ASC, `completedAt` DESC

4. **drawings**
   - `userId` ASC, `createdAt` DESC
   - `templateId` ASC, `createdAt` DESC

5. **teacher_student_links**
   - `teacherId` ASC, `status` ASC
   - `studentId` ASC, `status` ASC

6. **skill_assessments**
   - `studentId` ASC, `date` DESC

7. **schedules**
   - `studentId` ASC, `startTime` ASC
   - `teacherId` ASC, `startTime` ASC

## Bảo mật

Firestore Security Rules được cấu hình để đảm bảo:

1. Người dùng chỉ có thể đọc/ghi dữ liệu của chính mình
2. Giáo viên có thể đọc dữ liệu của học sinh được liên kết
3. Phụ huynh có thể đọc dữ liệu của con mình
4. Dữ liệu công khai (như bài kiểm tra đã xuất bản) có thể được đọc bởi tất cả người dùng

## Quan hệ dữ liệu

- Một **user** có thể có nhiều **quizzes** (nếu là giáo viên hoặc phụ huynh)
- Một **quiz** có nhiều **questions**
- Một **user** có nhiều **user_progress**
- Một **user** có nhiều **badges** (thông qua **user_badges**)
- Một **user** có nhiều **rewards** (thông qua **user_rewards**)
- Một **teacher** có thể liên kết với nhiều **students** (thông qua **teacher_student_links**)
- Một **student** có thể có nhiều **skill_assessments**
- Một **student** có thể có nhiều **schedules**
