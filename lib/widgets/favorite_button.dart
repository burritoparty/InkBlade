import 'package:flutter/material.dart';
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle;
  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onFavoriteToggle(!isFavorite),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
      ),
      label: const Text('Favorite'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFavorite ? Colors.blueAccent : Colors.grey[800],
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}