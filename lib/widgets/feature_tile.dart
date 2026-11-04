import 'package:flutter/material.dart';
import '../screens/features.dart';

class FeatureTile extends StatelessWidget {
  final Feature feature;
  const FeatureTile({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final enabled = feature.available;
    final color = enabled ? feature.color : Colors.grey;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (enabled) {
            Navigator.of(context).push(MaterialPageRoute(builder: feature.builder));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${feature.title} segera hadir'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color.withOpacity(0.14),
                    child: Icon(feature.icon, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!enabled)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Segera',
                      style: TextStyle(fontSize: 8, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
