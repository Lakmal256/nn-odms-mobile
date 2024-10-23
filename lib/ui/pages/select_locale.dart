import 'package:flutter/material.dart';
import 'package:odms/ui/ui.dart';

class SelectLocaleView extends StatelessWidget {
  const SelectLocaleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 7,
            child: Image.asset(
              "assets/images/tm_001.png",
              fit: BoxFit.scaleDown,
            ),
          ),
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Choose your language",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: const [
                LanguageListItem(title: "සිංහල"),
                SizedBox(height: 10),
                LanguageListItem(title: "English", isSelected: true),
                SizedBox(height: 10),
                LanguageListItem(title: "தமிழ்"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FilledButton(
              onPressed: () {},
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
                backgroundColor: MaterialStateProperty.all(const Color(0xFFDB4633)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              child: const Text("CONTINUE"),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageListItem extends StatelessWidget {
  const LanguageListItem({
    Key? key,
    required this.title,
    this.isSelected = false,
  }) : super(key: key);

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              // color: Colors.lightGreen,
              color: AppColors.red,
            ),
        ],
      ),
    );
  }
}
