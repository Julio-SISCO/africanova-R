import 'package:africanova/static/theme.dart';
import 'package:flutter/material.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 100,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35 - 30
                    ,
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: couleurFond2,
                    ),
                  ),
                ),
                const Text(
                  'Dreams Production',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: couleurFond2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
