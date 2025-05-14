import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/badge_model.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';

class UserAvatarWithBadge extends StatelessWidget {
  final String userId;
  final String displayName;
  final double radius;
  final BadgeModel? currentBadge;

  const UserAvatarWithBadge({
    Key? key,
    required this.userId,
    required this.displayName,
    this.radius = 30,
    this.currentBadge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
            style: TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        if (currentBadge != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 2,
                ),
              ),
              child: currentBadge!.imageUrl.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: currentBadge!.imageUrl,
                        width: radius * 0.6,
                        height: radius * 0.6,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => SizedBox(
                          width: radius * 0.6,
                          height: radius * 0.6,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue.shade300,
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: radius * 0.3,
                          backgroundColor: Colors.amber,
                          child: Icon(
                            Icons.emoji_events,
                            size: radius * 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: radius * 0.3,
                      backgroundColor: Colors.amber,
                      child: Icon(
                        Icons.emoji_events,
                        size: radius * 0.4,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}