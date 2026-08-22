class Review {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String bookId;
  final int rating;
  final String comment;
  final int createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto = '',
    required this.bookId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhoto: map['userPhoto'] as String? ?? '',
      bookId: map['bookId'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'bookId': bookId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
