import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../locator.dart';
import '../../service/service.dart';
import '../../util/storage.dart';
import '../ui.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<UserResponseDto?> action;
  UserResponseDto? userResponseData;

  @override
  void initState() {
    refreshUserData();
    super.initState();
  }

  Future<void> _fetchUser() async {
    Storage storage = Storage();
    String? email = await storage.readValue("email");
    final data = await locate<RestService>().getUserByEmail(email!);
    setState(() {
      userResponseData = data;
      action = Future.value(data);
    });
  }

  Future<void> refreshUserData() async {
    await _fetchUser();
  }

  handleLogout(BuildContext context) async {
    bool? ok = await showLogoutConfirmationDialog(context);

    if (ok != null && ok) {
      TokenProvider tokenProvider = locate<TokenProvider>();
      await tokenProvider.endSession();
      await tokenProvider.clearSession();

      if (context.mounted) {
        return context.go("/login/credentials");
      }
    }

    return;
  }

  final validRolesForCreateSO = [
    "Call Center User",
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "Super Admin"
  ];

  final validRolesForManageSO = [
    "Call Center User",
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "Customer Support User",
    "Finance User",
    "Commercial User",
    "Logistics Other",
    "DPMC User",
    "Super Admin"
  ];

  final validRolesForCreateDO = [
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "DPMC User",
    "Transporter",
    "Super Admin"
  ];

  final validRolesForManageDO = [
    "Call Center User",
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "Customer Support User",
    "Finance User",
    "Commercial User",
    "Logistics Other",
    "DPMC User",
    "Transporter",
    "Super Admin"
  ];

  final validRolesForAccounts = [
    "Call Center User",
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "Customer Support User",
    "Finance User",
    "Commercial User",
    "Super Admin"
  ];

  final validRolesForReports = [
    "Call Center User",
    "B2B Sales User/AM",
    "Retail Sales User",
    "Business Administrator",
    "Customer Admin",
    "Customer User",
    "Customer Support User",
    "Finance User",
    "Commercial User",
    "Logistics Other",
    "DPMC User",
    "Transporter",
    "Super Admin"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: AspectRatio(
                  aspectRatio: 5,
                  child: Row(
                    children: [
                      if (userResponseData != null)
                        AspectRatio(
                          aspectRatio: 1,
                          child: DrawerAvatar(data: userResponseData!),
                        )
                      else
                        Container(
                          color: Colors.blue,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  "${userResponseData?.firstName ?? "N/A"} ${userResponseData?.lastName ?? "N/A"}",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  userResponseData?.roles?.first.roleName ?? "N/A",
                                  style:
                                      Theme.of(context).textTheme.titleSmall?.copyWith(color: const Color(0xff7c7c7c)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        DrawerListItem(
                          path: "/home",
                          icon: Icon(
                            Icons.home_outlined,
                            color: GoRouter.of(context).location == "/home"
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF717579),
                          ),
                          title: "Dashboard",
                          onSelect: () => GoRouter.of(context).go("/home"),
                        ),
                        const SizedBox(height: 5),
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                          const SizedBox(height: 20),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const DrawerListTitle(
                            title: "Sales Orders",
                          ),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const SizedBox(height: 5),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const Divider(
                            color: Color(0xFFD9D9D9),
                            thickness: 2,
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const SizedBox(height: 5),
                        if (validRolesForCreateSO.contains(userResponseData?.roles?.first.roleName))
                          DrawerListItem(
                            path: "/order-retail-credit-view",
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color: GoRouter.of(context).location == "/order-retail-credit-view"
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717579),
                            ),
                            title: "Create Order",
                            onSelect: () => GoRouter.of(context).go("/order-retail-credit-view"),
                          ),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          DrawerListItem(
                            path: "/view-sales-orders",
                            icon: Icon(Icons.file_open_outlined,
                                color: GoRouter.of(context).location == "/view-sales-orders"
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF717579)),
                            title: "Manage Orders",
                            onSelect: () => GoRouter.of(context).go("/view-sales-orders"),
                          ),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const SizedBox(height: 5),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                          const Divider(
                            color: Color(0xFFD9D9D9),
                            thickness: 2,
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                        if (validRolesForManageSO.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 20),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const DrawerListTitle(
                          title: "Delivery",
                        ),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForCreateDO.contains(userResponseData?.roles?.first.roleName))
                        DrawerListItem(
                          path: "/delivery-order-creation-view",
                          icon: Icon(
                            Icons.local_shipping_outlined,
                            color: GoRouter.of(context).location == "/delivery-order-creation-view"
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF717579).withOpacity(0.4),
                          ),
                          title: "Create Delivery",
                          // onSelect: () => GoRouter.of(context).go("/delivery-order-creation-view"),
                          onSelect: () {},
                        ),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        DrawerListItem(
                          path: "/view-orders",
                          icon: Icon(
                            Icons.file_open_outlined,
                            color: GoRouter.of(context).location == "/view-orders"
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF717579).withOpacity(0.4),
                          ),
                          title: "Manage Delivery",
                          // onSelect: () => GoRouter.of(context).go("/view-orders"),
                          onSelect: () {},
                        ),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        if (validRolesForManageDO.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 20),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const DrawerListTitle(
                          title: "Accounts",
                        ),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        DrawerListItem(
                          path: "/view-payments",
                          icon: Icon(Icons.credit_card_outlined,
                              color: GoRouter.of(context).location == "/view-payments"
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717579)),
                          title: "Accounts & Payments",
                          onSelect: () => GoRouter.of(context).go("/view-payments"),
                          // onSelect: () {},
                        ),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        if (validRolesForAccounts.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 20),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const DrawerListTitle(
                          title: "Reports",
                        ),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        DrawerListItem(
                          path: "/view-reports-filter",
                          icon: Icon(Icons.list_alt_outlined,
                              color: GoRouter.of(context).location == "/view-reports-filter"
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF717579)),
                          title: "Reports",
                          onSelect: () => GoRouter.of(context).go("/view-reports-filter"),
                          // onSelect: () {},
                        ),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const SizedBox(height: 5),
                        if (validRolesForReports.contains(userResponseData?.roles?.first.roleName))
                        const Divider(
                          color: Color(0xFFD9D9D9),
                          thickness: 2,
                          height: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        const SizedBox(height: 30),
                        FilledButton(
                          onPressed: () => handleLogout(context),
                          style: ButtonStyle(
                            visualDensity: VisualDensity.standard,
                            minimumSize: MaterialStateProperty.all(const Size.fromHeight(45)),
                            backgroundColor: MaterialStateProperty.all(const Color(0xFF717579)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text("Log Out"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [Expanded(child: widget.child), BottomNavigation(refreshUserData: refreshUserData)],
      ),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  final VoidCallback refreshUserData;
  const BottomNavigation({Key? key, required this.refreshUserData}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomNavigationItem(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                  widget.refreshUserData();
                },
                icon: Image.asset("assets/images/nav/nav_001.png"),
              ),
              BottomNavigationItem(
                onTap: () {
                  GoRouter.of(context).go("/home");
                },
                icon: Image.asset("assets/images/nav/nav_002.png",
                    color:
                        GoRouter.of(context).location == "/home" ? Theme.of(context).colorScheme.primary : Colors.grey),
              ),
              BottomNavigationItem(
                // disabled: true,
                onTap: () {
                  GoRouter.of(context).go("/my_profile");
                },
                icon: Image.asset("assets/images/nav/nav_003.png",
                    color: GoRouter.of(context).location == "/my_profile"
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    Key? key,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  }) : super(key: key);

  final Widget icon;
  final Function() onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed: onTap,
      padding: const EdgeInsets.all(25),
    );
  }
}

class DrawerAvatar extends StatelessWidget {
  final UserResponseDto data;
  const DrawerAvatar({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage("https://ui-avatars.com/api/?background=random&name=${data.firstName}+"
              "${data.lastName}"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class DrawerListTitle extends StatelessWidget {
  const DrawerListTitle({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xff717576),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DrawerListItem extends StatelessWidget {
  const DrawerListItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onSelect,
    required this.path,
  }) : super(key: key);
  final String title;
  final Icon icon;
  final void Function() onSelect;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GoRouter.of(context).location == path ? AppColors.red : const Color(0xFFFFFFFF),
      child: InkWell(
        onTap: () {
          onSelect();
          Scaffold.of(context).openEndDrawer();
        },
        splashColor: const Color(0xFFDB4633),
        overlayColor: MaterialStateProperty.all(const Color(0xFFDB4633)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: GoRouter.of(context).location == path ? const Color(0xFFFFFFFF) : const Color(0xff6E726E),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
