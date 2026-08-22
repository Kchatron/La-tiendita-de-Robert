class Purchase {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final double price;
  final String paymentMethod;
  final String paymentStatus;
  final int createdAt;

  Purchase({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    this.bookCover = '',
    required this.price,
    this.paymentMethod = 'Tarjeta',
    this.paymentStatus = 'completed',
    required this.createdAt,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] as String,
      userId: map['userId'] as String,
      bookId: map['bookId'] as String,
      bookTitle: map['bookTitle'] as String,
      bookCover: map['bookCover'] as String? ?? '',
      price: (map['price'] as num? ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] as String? ?? 'Tarjeta',
      paymentStatus: map['paymentStatus'] as String? ?? 'completed',
      createdAt: map['createdAt'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookCover': bookCover,
      'price': price,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
    };
  }
}

class LibraryItem {
  final String id;
  final String userId;
  final String bookId;
  final String source;
  final int acquiredAt;
  final bool isDownloaded;
  final int? downloadedAt;
  final String? localFilePath;

  LibraryItem({
    required this.id,
    required this.userId,
    required this.bookId,
    this.source = SOURCE_FREE,
    required this.acquiredAt,
    this.isDownloaded = false,
    this.downloadedAt,
    this.localFilePath,
  });

  static const String SOURCE_FREE = 'free';
  static const String SOURCE_PURCHASE = 'purchase';

  factory LibraryItem.fromMap(Map<String, dynamic> map) {
    return LibraryItem(
      id: map['id'] as String,
      userId: map['userId'] as String,
      bookId: map['bookId'] as String,
      source: map['source'] as String? ?? SOURCE_FREE,
      acquiredAt: map['acquiredAt'] as int,
      isDownloaded: (map['isDownloaded'] as int? ?? 0) == 1,
      downloadedAt: map['downloadedAt'] as int?,
      localFilePath: map['localFilePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'source': source,
      'acquiredAt': acquiredAt,
      'isDownloaded': isDownloaded ? 1 : 0,
      'downloadedAt': downloadedAt,
      'localFilePath': localFilePath,
    };
  }

  LibraryItem copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? source,
    int? acquiredAt,
    bool? isDownloaded,
    int? downloadedAt,
    String? localFilePath,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      source: source ?? this.source,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }
}

class FavoriteItem {
  final String id;
  final String userId;
  final String bookId;
  final int createdAt;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] as String,
      userId: map['userId'] as String,
      bookId: map['bookId'] as String,
      createdAt: map['createdAt'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'createdAt': createdAt,
    };
  }
}

class AuthorStats {
  final int totalBooks;
  final int totalViews;
  final int totalDownloads;
  final double averageRating;
  final int totalSales;
  final double simulatedRevenue;

  AuthorStats({
    this.totalBooks = 0,
    this.totalViews = 0,
    this.totalDownloads = 0,
    this.averageRating = 0.0,
    this.totalSales = 0,
    this.simulatedRevenue = 0.0,
  });
}

class AdminStats {
  final int totalUsers;
  final int totalBooks;
  final int pendingBooks;
  final int approvedBooks;
  final int totalDownloads;
  final double simulatedRevenue;
  final int totalReviews;

  AdminStats({
    this.totalUsers = 0,
    this.totalBooks = 0,
    this.pendingBooks = 0,
    this.approvedBooks = 0,
    this.totalDownloads = 0,
    this.simulatedRevenue = 0.0,
    this.totalReviews = 0,
  });
}
