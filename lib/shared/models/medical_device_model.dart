/// Medical Device Model - نموذج الجهاز الطبي
class MedicalDeviceModel {
  MedicalDeviceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.inStock = true,
  });

  factory MedicalDeviceModel.fromJson(Map<String, dynamic> json) =>
      MedicalDeviceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String?,
        category: json['category'] as String,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewsCount: json['reviewsCount'] as int? ?? 0,
        inStock: json['inStock'] as bool? ?? true,
      );
  final String id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final String category;
  final double rating;
  final int reviewsCount;
  final bool inStock;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'category': category,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'inStock': inStock,
  };
}

/// Mock Medical Devices
class MockMedicalDevices {
  static List<MedicalDeviceModel> getDevices() => [
    MedicalDeviceModel(
      id: '1',
      name: 'جهاز قياس الضغط الرقمي',
      description: 'جهاز قياس ضغط الدم الرقمي عالي الدقة',
      price: 299,
      category: 'أجهزة القياس',
      rating: 4.5,
      reviewsCount: 120,
    ),
    MedicalDeviceModel(
      id: '2',
      name: 'جهاز قياس السكر',
      description: 'جهاز قياس نسبة السكر في الدم مع شرائط',
      price: 199,
      category: 'أجهزة القياس',
      rating: 4.7,
      reviewsCount: 95,
    ),
    MedicalDeviceModel(
      id: '3',
      name: 'ميزان حرارة رقمي',
      description: 'ميزان حرارة رقمي سريع ودقيق',
      price: 49,
      category: 'أجهزة القياس',
      rating: 4.3,
      reviewsCount: 200,
    ),
    MedicalDeviceModel(
      id: '4',
      name: 'جهاز قياس الأكسجين',
      description: 'جهاز قياس نسبة الأكسجين في الدم',
      price: 149,
      category: 'أجهزة القياس',
      rating: 4.6,
      reviewsCount: 80,
    ),
    MedicalDeviceModel(
      id: '5',
      name: 'جهاز استنشاق البخار',
      description: 'جهاز استنشاق البخار للأطفال والكبار',
      price: 399,
      category: 'أجهزة العلاج',
      rating: 4.4,
      reviewsCount: 60,
    ),
    MedicalDeviceModel(
      id: '6',
      name: 'وسادة طبية للرقبة',
      description: 'وسادة طبية مريحة لآلام الرقبة',
      price: 179,
      category: 'مستلزمات طبية',
      rating: 4.2,
      reviewsCount: 150,
    ),
  ];
}
