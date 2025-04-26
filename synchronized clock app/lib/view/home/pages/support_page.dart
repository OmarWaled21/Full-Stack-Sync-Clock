import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synchronized_clock/core/colors.dart';
import 'package:synchronized_clock/core/helper/lang_extention.dart';
import 'package:synchronized_clock/core/helper/navigator_extention.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
        ),
        title: Text(
          context.lang.supports,
          style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              children: [
                supportTextField(
                  title: ('website'),
                  link: 'https://tomatiki.com',
                  icon: CupertinoIcons.link,
                  color: Colors.blueGrey,
                ),
                supportTextField(
                  title: ('phone'),
                  link: '01012345678',
                  icon: CupertinoIcons.phone_solid,
                  color: Colors.deepOrange,
                  isPhone: true, // Indicates it's a phone number
                ),
                supportTextField(
                  title: ('whatsapp'),
                  link: 'https://wa.me/01012345678',
                  icon: CupertinoIcons.phone_circle_fill,
                  color: AppColors.successColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget supportTextField({
  required String title,
  required String link,
  required IconData icon,
  required Color color,
  bool isPhone = false, // Added flag to detect phone numbers
}) {
  return TextField(
    controller: TextEditingController(text: link),
    readOnly: true,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      prefixIcon: Icon(icon, color: color),
      labelText: title,
      labelStyle: TextStyle(color: color),
    ),
    onTap: () {
      _launchURL(link, isPhone);
    },
  );
}

void _launchURL(String urlLink, bool isPhone) async {
  final Uri url = isPhone ? Uri.parse("tel:$urlLink") : Uri.parse(urlLink);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Could not launch $url");
  }
}
