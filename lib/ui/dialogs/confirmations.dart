import 'package:flutter/material.dart';

Future<bool?> showLogoutConfirmationDialog(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Container(
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0),
            ),
            color: Color(0xFFF26066),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  "Logout?",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        content: Row(
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Are you sure you want to log out?",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFF000000),
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Divider(
                    color: Color(0xFFE9E9E9),
                    thickness: 1,
                    height: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFF26066)),
                      ),
                      child: Text(
                        "Ok",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFFFFFFFF),
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFD3D3D3)),
                      ),
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFF000000),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

Future<bool?> itemRemoveConfirmationDialog(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Container(
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            color: Color(0xFFF26066),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  "Cancel Action",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        content: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Are you sure you want to remove\nthis item?",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFF000000),
                    ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Divider(
                    color: Color(0xFFE9E9E9),
                    thickness: 1,
                    height: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFF26066)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFFEEEEEE)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: const Color(0xFF3E4954).withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

Future<void> cancelOrderSuccessfulDialog(BuildContext context) => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Container(
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            color: Color(0xFFF26066),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  "Cancel Action",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: const Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Icon(Icons.check_circle_outline, color: Color(0xFF63BB43), size: 50),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Canceled Successfully",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: const Color(0xFF000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );

Future<bool?> cancelOrderConfirmationDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    titlePadding: EdgeInsets.zero,
    contentPadding: EdgeInsets.zero,
    actionsPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    title: Container(
      height: 50,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        color: Color(0xFFF26066),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              "Cancel Action",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    content: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            "Are you sure you want to cancel\nthis sales order?",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: const Color(0xFF000000),
            ),
          ),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Divider(
                color: Color(0xFFE9E9E9),
                thickness: 1,
                height: 1,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFFF26066)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Confirm",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFFEEEEEE)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: const Color(0xFF3E4954).withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

Future<void> updateOrderSuccessfulDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    titlePadding: EdgeInsets.zero,
    contentPadding: EdgeInsets.zero,
    actionsPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    title: Container(
      height: 50,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        color: Color(0xFFF26066),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              "Update Action",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
    content: const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Icon(Icons.check_circle_outline, color: Color(0xFF63BB43), size: 50),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            "Updated Successfully",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: const Color(0xFF000000),
            ),
          ),
        ),
      ),
    ],
  ),
);

Future<bool?> showCustomerTncConfirmationDialog(BuildContext context) {
  bool checked = false;
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            title: Container(
              height: 50,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
                color: Color(0xFFF26066),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          "Terms and Conditions",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      child: Text(
                        "By checking this box, I state that\nI have read, understood, and \naccepted the terms and conditions"
                            "\nby Siam City Cement (Lanka) Pvt Ltd.",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Align(
                      alignment : Alignment.centerLeft,
                      child: Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.red,
                        value: checked,
                        onChanged: (value) {
                          setState(() {
                            checked = value!;
                          });
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Divider(
                        color: Color(0xFFE9E9E9),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            checked ? Navigator.of(context).pop(checked) : null;
                          },
                          style: ButtonStyle(
                            backgroundColor: checked
                                ? MaterialStateProperty.all(const Color(0xFFF26066))
                                : MaterialStateProperty.all(Colors.grey),
                          ),
                          child: Text(
                            "Continue",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      });
}
