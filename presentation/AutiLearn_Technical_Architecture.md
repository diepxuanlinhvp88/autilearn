# Kiến trúc kỹ thuật AutiLearn

## Tổng quan kiến trúc

AutiLearn được xây dựng theo mô hình Clean Architecture kết hợp với BLoC pattern để quản lý trạng thái. Kiến trúc này giúp tách biệt các thành phần của ứng dụng, dễ dàng bảo trì và mở rộng.

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Presentation Layer (UI, BLoC)                      │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Domain Layer (Use Cases, Entities)                 │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Data Layer (Repositories, Data Sources)            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Các lớp chính trong kiến trúc

### 1. Presentation Layer

- **Pages**: Các màn hình UI của ứng dụng
- **Widgets**: Các thành phần UI có thể tái sử dụng
- **BLoCs**: Quản lý trạng thái và logic nghiệp vụ cho UI
  - Events: Các sự kiện từ UI
  - States: Các trạng thái của UI
  - BLoC: Xử lý events và tạo ra states

### 2. Domain Layer

- **Entities**: Các đối tượng nghiệp vụ cốt lõi
- **Use Cases**: Các trường hợp sử dụng của ứng dụng
- **Repository Interfaces**: Định nghĩa các phương thức truy cập dữ liệu

### 3. Data Layer

- **Repositories**: Triển khai các repository interfaces
- **Data Sources**: Nguồn dữ liệu (Firebase, Local Storage)
- **Models**: Các đối tượng dữ liệu

## Luồng dữ liệu

1. UI gửi Event đến BLoC
2. BLoC xử lý Event và gọi Use Case
3. Use Case tương tác với Repository
4. Repository lấy dữ liệu từ Data Source
5. Dữ liệu được trả về theo chiều ngược lại
6. BLoC cập nhật State
7. UI cập nhật dựa trên State mới

## Công nghệ sử dụng

### Frontend
- **Flutter**: Framework UI đa nền tảng
- **Dart**: Ngôn ngữ lập trình
- **flutter_bloc**: Quản lý trạng thái
- **get_it**: Dependency Injection
- **equatable**: So sánh đối tượng
- **dartz**: Functional Programming (Either type)

### Backend
- **Firebase Authentication**: Xác thực người dùng
- **Cloud Firestore**: Cơ sở dữ liệu NoSQL
- **Firebase Storage**: Lưu trữ file
- **Firebase Analytics**: Phân tích người dùng

## Cấu trúc thư mục

```
lib/
├── app/                  # App configuration
│   ├── app.dart          # App entry point
│   └── routes.dart       # App routes
├── core/                 # Core functionality
│   ├── constants/        # App constants
│   ├── error/            # Error handling
│   ├── services/         # Core services
│   └── utils/            # Utility functions
├── data/                 # Data layer
│   ├── datasources/      # Data sources
│   ├── models/           # Data models
│   └── repositories/     # Repository implementations
├── domain/               # Domain layer
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Use cases
├── presentation/         # Presentation layer
│   ├── blocs/            # BLoCs
│   ├── pages/            # App screens
│   └── widgets/          # Reusable widgets
└── main.dart             # Entry point
```

## Mô hình dữ liệu

### Collections chính trong Firestore

- **users**: Thông tin người dùng
- **quizzes**: Thông tin bài kiểm tra
- **questions**: Câu hỏi cho bài kiểm tra
- **user_progress**: Tiến độ học tập của người dùng
- **badges**: Huy hiệu thành tích
- **rewards**: Phần thưởng
- **drawing_templates**: Mẫu vẽ
- **drawings**: Bản vẽ của người dùng
- **analytics**: Phân tích dữ liệu học tập
- **teacher_student_links**: Liên kết giáo viên-học sinh
- **skill_assessments**: Đánh giá kỹ năng
- **schedules**: Lịch học

## Quản lý trạng thái với BLoC

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│             │    │             │    │             │
│     UI      │───▶│    Event    │───▶│    BLoC     │
│             │    │             │    │             │
└─────────────┘    └─────────────┘    └──────┬──────┘
       ▲                                      │
       │                                      │
       │                                      ▼
┌─────────────┐                        ┌─────────────┐
│             │                        │             │
│    State    │◀───────────────────────│  Repository │
│             │                        │             │
└─────────────┘                        └─────────────┘
```

## Dependency Injection

Sử dụng `get_it` để quản lý các dependency trong ứng dụng:

```dart
final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  
  // Data sources
  getIt.registerLazySingleton<FirebaseDataSource>(
    () => FirebaseDataSource(firebaseService: getIt())
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(firebaseDataSource: getIt())
  );
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(authRepository: getIt()));
}
```

## Xử lý lỗi

Sử dụng `Either` từ package `dartz` để xử lý lỗi một cách functional:

```dart
Future<Either<Failure, UserModel>> getUserProfile(String userId) async {
  try {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return Left(NotFoundFailure('User not found'));
    }
    
    return Right(UserModel.fromFirestore(userDoc));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

## Bảo mật

- **Firebase Authentication**: Xác thực người dùng
- **Firestore Security Rules**: Kiểm soát quyền truy cập dữ liệu
- **Firebase Storage Rules**: Kiểm soát quyền truy cập file
- **Client-side validation**: Kiểm tra dữ liệu đầu vào

## Hiệu suất

- **Lazy loading**: Tải dữ liệu khi cần thiết
- **Caching**: Lưu trữ dữ liệu tạm thời
- **Pagination**: Phân trang dữ liệu lớn
- **Image optimization**: Tối ưu hóa hình ảnh
