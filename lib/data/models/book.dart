class Book {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorId;
  final String categoryId;
  final String coverUrl;
  final String pdfStoragePath;
  final String pdfFileName;
  final double fileSizeMb;
  final double price;
  final String language;
  final int publicationYear;
  final String isbn;
  final int pageCount;
  final double ratingAverage;
  final int ratingCount;
  final int viewCount;
  final int downloadCount;
  final String status;
  final String? rejectionReason;
  final int createdAt;
  final int updatedAt;
  final int? approvedAt;

  Book({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.categoryId,
    this.coverUrl = '',
    this.pdfStoragePath = '',
    this.pdfFileName = 'document.pdf',
    this.fileSizeMb = 3.5,
    this.price = 0.0,
    this.language = 'Español',
    this.publicationYear = 2024,
    this.isbn = '',
    this.pageCount = 180,
    this.ratingAverage = 0.0,
    this.ratingCount = 0,
    this.viewCount = 0,
    this.downloadCount = 0,
    this.status = STATUS_PENDING,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
  });

  bool get isFree => price <= 0.0;
  bool get isApproved => status == STATUS_APPROVED;
  bool get isPending => status == STATUS_PENDING;
  bool get isRejected => status == STATUS_REJECTED;
  bool get isDraft => status == STATUS_DRAFT;
  bool get isSuspended => status == STATUS_SUSPENDED;

  static const String STATUS_DRAFT = 'draft';
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_APPROVED = 'approved';
  static const String STATUS_REJECTED = 'rejected';
  static const String STATUS_SUSPENDED = 'suspended';

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      authorId: map['authorId'] as String,
      categoryId: map['categoryId'] as String,
      coverUrl: map['coverUrl'] as String? ?? '',
      pdfStoragePath: map['pdfStoragePath'] as String? ?? '',
      pdfFileName: map['pdfFileName'] as String? ?? 'libro.pdf',
      fileSizeMb: (map['fileSizeMb'] as num? ?? 3.5).toDouble(),
      price: (map['price'] as num? ?? 0.0).toDouble(),
      language: map['language'] as String? ?? 'Español',
      publicationYear: map['publicationYear'] as int? ?? 2024,
      isbn: map['isbn'] as String? ?? '',
      pageCount: map['pageCount'] as int? ?? 180,
      ratingAverage: (map['ratingAverage'] as num? ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      downloadCount: map['downloadCount'] as int? ?? 0,
      status: map['status'] as String? ?? STATUS_PENDING,
      rejectionReason: map['rejectionReason'] as String?,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      approvedAt: map['approvedAt'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId,
      'categoryId': categoryId,
      'coverUrl': coverUrl,
      'pdfStoragePath': pdfStoragePath,
      'pdfFileName': pdfFileName,
      'fileSizeMb': fileSizeMb,
      'price': price,
      'language': language,
      'publicationYear': publicationYear,
      'isbn': isbn,
      'pageCount': pageCount,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approvedAt': approvedAt,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? authorId,
    String? categoryId,
    String? coverUrl,
    String? pdfStoragePath,
    String? pdfFileName,
    double? fileSizeMb,
    double? price,
    String? language,
    int? publicationYear,
    String? isbn,
    int? pageCount,
    double? ratingAverage,
    int? ratingCount,
    int? viewCount,
    int? downloadCount,
    String? status,
    String? rejectionReason,
    int? createdAt,
    int? updatedAt,
    int? approvedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      categoryId: categoryId ?? this.categoryId,
      coverUrl: coverUrl ?? this.coverUrl,
      pdfStoragePath: pdfStoragePath ?? this.pdfStoragePath,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      price: price ?? this.price,
      language: language ?? this.language,
      publicationYear: publicationYear ?? this.publicationYear,
      isbn: isbn ?? this.isbn,
      pageCount: pageCount ?? this.pageCount,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
