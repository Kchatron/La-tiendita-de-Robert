import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final Function(int)? onRatingChanged;

  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18,
    this.color = Colors.amber,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData iconData;

        if (rating >= starValue) {
          iconData = Icons.star;
        } else if (rating > index && rating < starValue) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_border;
        }

        final starIcon = Icon(
          iconData,
          size: size,
          color: color,
        );

        if (onRatingChanged != null) {
          return GestureDetector(
            onTap: () => onRatingChanged!(starValue),
            child: starIcon,
          );
        }

        return starIcon;
      }),
    );
  }
}
