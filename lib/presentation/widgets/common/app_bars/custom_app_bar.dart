import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool showHelpButton;
  final String? helpMessage;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.actions,
    this.showHelpButton = false,
    this.helpMessage,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> finalActions = [...?actions];
    
    if (showHelpButton) {
      finalActions.add(
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            if (helpMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(helpMessage!),
                ),
              );
            }
          },
        ),
      );
    }

    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Colors.blue,
      foregroundColor: Colors.white,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading,
      actions: finalActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 