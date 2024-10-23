import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../widgets.dart';
import 'package:go_router/go_router.dart';

class ActiveUserListView extends StatefulWidget {
  const ActiveUserListView({Key? key}) : super(key: key);

  @override
  State<ActiveUserListView> createState() => _ActiveUserListViewState();
}

class _ActiveUserListViewState extends State<ActiveUserListView> {
  late Future action;

  @override
  void initState() {
    super.initState();
    action = locate<ActiveUserListService>().fetchCustomerActiveUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbfcf8),
      appBar: const AppBarWithTM(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.7,
                      child: BackButton(
                        onPressed: () => GoRouter.of(context).go("/home"),
                      ),
                    ),
                    Text(
                      "Active User List",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: action,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ValueListenableBuilder(
                  valueListenable: locate<ActiveUserListService>(),
                  builder: (context, snapshot, _) {
                    if (snapshot.activeUserList.isEmpty) {
                      return const Center(
                        child: FittedBox(child: Text("There are no Active Users.")),
                      );
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.activeUserList
                          .map(
                            (activeUser) => ActiveUserCard(
                              firstName: activeUser.firstName ?? "N/A",
                              lastName: activeUser.lastName ?? "N/A",
                              mobileNumber: activeUser.mobileNo ?? "N/A",
                              sapEmployeeNumber: activeUser.sapEmployeeCode ?? "N/A",
                              userRole: activeUser.roles!.first.roleName ?? "N/A",
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ActiveUserCard extends StatelessWidget {
  const ActiveUserCard({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.sapEmployeeNumber,
    required this.userRole,
  }) : super(key: key);

  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String sapEmployeeNumber;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.width >= 360
              ? 120.0 : 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                "Name",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w700,
                                    ),
                              )
                            : Text(
                                "Name",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                      ),
                      FittedBox(
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                "$firstName $lastName",
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: const Color(0xFF1D1B23),
                                      fontWeight: FontWeight.w300,
                                    ),
                              )
                            : Text(
                                "$firstName $lastName",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: const Color(0xFF1D1B23),
                                      fontWeight: FontWeight.w300,
                                    ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                "Mobile Number",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                      color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w700,
                                    ),
                              )
                            : Text(
                                "Mobile Number",
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                      ),
                      FittedBox(
                        child: MediaQuery.of(context).size.width >= 360
                            ? Text(
                                mobileNumber,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: const Color(0xFF1D1B23),
                                      fontWeight: FontWeight.w300,
                                    ),
                              )
                            : Text(
                                mobileNumber,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: const Color(0xFF1D1B23),
                                      fontWeight: FontWeight.w300,
                                    ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "Statement",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              : Text(
                                  "Statement",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                        ),
                        FittedBox(
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  userRole,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                                )
                              : Text(
                                  userRole,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  "SAP Emp No",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                )
                              : Text(
                                  "SAP Emp No",
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: const Color(0xFF000000),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        FittedBox(
                          child: MediaQuery.of(context).size.width >= 360
                              ? Text(
                                  sapEmployeeNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w600),
                                )
                              : Text(
                                  sapEmployeeNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: const Color(0xFF173C79), fontWeight: FontWeight.w600),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
