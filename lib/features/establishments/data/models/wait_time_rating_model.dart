class WaitTimeRatingModel {
  final int rating;

  WaitTimeRatingModel({required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
    };
  }
}
