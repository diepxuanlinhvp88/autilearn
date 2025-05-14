import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  final FirebaseFirestore _firestore;

  BadgeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createSampleBadges() async {
    final badges = [
      {
        'name': 'Huy hiệu Đồng',
        'description': 'Bắt đầu hành trình học tập',
        'imageUrl': 'https://i.imgur.com/dLR666f.png',
        'category': 'rank',
        'requiredPoints': 0,
        'isDefault': true,
      },
      {
        'name': 'Huy hiệu Bạc',
        'description': 'Đã hoàn thành nhiều bài học',
        'imageUrl': 'https://i.imgur.com/omCbD79.png',
        'category': 'rank',
        'requiredPoints': 100,
        'isDefault': false,
      },
      {
        'name': 'Huy hiệu Vàng',
        'description': 'Thành tích học tập xuất sắc',
        'imageUrl': 'https://i.imgur.com/UMdw97J.png',
        'category': 'rank',
        'requiredPoints': 500,
        'isDefault': false,
      },
      {
        'name': 'Huy hiệu Bạch Kim',
        'description': 'Kiến thức vững vàng',
        'imageUrl': 'https://imgur.com/IcFInJp',
        'category': 'rank',
        'requiredPoints': 1000,
        'isDefault': false,
      },
      {
        'name': 'Huy hiệu Kim Cương',
        'description': 'Bậc thầy tri thức',
        'imageUrl': 'https://imgur.com/UMdw97J',
        'category': 'rank',
        'requiredPoints': 2000,
        'isDefault': false,
      },
    ];

    final batch = _firestore.batch();
    final badgesCollection = _firestore.collection('badges');

    // Kiểm tra xem đã có huy hiệu nào chưa
    final existingBadges = await badgesCollection.get();
    if (existingBadges.docs.isNotEmpty) {
      print('Badges already exist. Skipping sample badge creation.');
      return;
    }

    // Thêm từng huy hiệu vào batch
    for (final badge in badges) {
      final docRef = badgesCollection.doc();
      batch.set(docRef, {
        ...badge,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Thực hiện batch write
    await batch.commit();
    print('Sample badges created successfully');
  }

  Future<void> updateBadgeUrls() async {
    final badgesCollection = _firestore.collection('badges');
    final badges = await badgesCollection.get();

    final batch = _firestore.batch();

    for (final doc in badges.docs) {
      final data = doc.data();
      final name = data['name'] as String;

      String? newImageUrl;
      if (name.contains('Đồng')) {
        newImageUrl = 'https://i.imgur.com/dLR666f.png';
      } else if (name.contains('Bạc')) {
        newImageUrl = 'https://i.imgur.com/omCbD79.png';
      } else if (name.contains('Vàng')) {
        newImageUrl = 'https://i.imgur.com/UMdw97J.png';
      } else if (name.contains('Bạch Kim')) {
        newImageUrl = 'https://i.imgur.com/IcFInJp.png';
      } else if (name.contains('Kim Cương')) {
        newImageUrl = 'https://i.imgur.com/UMdw97J.png';
      }

      if (newImageUrl != null) {
        batch.update(doc.reference, {
          'imageUrl': newImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
    print('Badge URLs updated successfully');
  }
}