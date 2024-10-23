import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odms/ui/_/repo_test.dart';
import 'ui/ui.dart';

ShellRoute loginFlowShellRoute = ShellRoute(
  builder: (context, state, child) => child,
  routes: [
    GoRoute(path: "/login", redirect: (context, state) => "/walkthrough"),
    GoRoute(
      path: "/walkthrough",
      builder: (context, state) => SplashWalkthrough(
        onDone: () async => context.go("/login/credentials"),
      ),
    ),
    GoRoute(
      path: "/login/credentials",
      builder: (context, state) => AuthFlowPage(
        child: LoginFormView(
          shouldSendOtp: true,
          onDone: (result) {
            if (result.changePasswordNextLogin) {
              return GoRouter.of(context).go(
                Uri(
                  path: "/change-password/two-factor-auth",
                  queryParameters: {
                    "email": result.formValue.uName,
                    "mobile": result.mobile,
                  },
                ).toString(),
              );
            } else if (result.isNewUser) {
              return GoRouter.of(context).go(Uri(
                path: "/login/two-factor-auth",
                queryParameters: {
                  "email": result.formValue.uName,
                  "mobile": result.mobile,
                },
              ).toString());
            }

            return GoRouter.of(context).go("/");
          },
          onResetPasswordPress: () => GoRouter.of(context).push("/password-reset"),
        ),
      ),
    ),
    GoRoute(
      path: "/login/two-factor-auth",
      builder: (context, state) => AuthFlowPage(
        child: OtpView(
          email: state.queryParams["email"],
          mobile: state.queryParams["mobile"],
          onDone: (value) => GoRouter.of(context).go("/"),
          onCancel: () {
            GoRouter.of(context).go("/login/credentials");
          },
          onResend: () {},
          controller: TextEditingController(),
        ),
      ),
    ),
  ],
);

ShellRoute passwordResetFlowShellRoute = ShellRoute(
  builder: (context, state, child) => child,
  routes: [
    GoRoute(path: "/password-reset", redirect: (context, state) => "/password-reset/identity"),
    GoRoute(
      path: "/password-reset/identity",
      builder: (context, state) => AuthFlowPage(
        child: UserIdentityFormView(
          onDone: (result) => GoRouter.of(context).go(Uri(
            path: "/password-reset/two-factor-auth",
            queryParameters: {
              "email": result.email,
              "mobile": result.mobile,
            },
          ).toString()),
        ),
      ),
    ),
    GoRoute(
      path: "/password-reset/two-factor-auth",
      builder: (context, state) => AuthFlowPage(
        child: OtpView(
          email: state.queryParams["email"],
          mobile: state.queryParams["mobile"],
          obfuscateMobile: true,
          onDone: (result) => GoRouter.of(context).go(
            "/password-reset/new-password/${result.authorizationCode}",
          ),
          onCancel: () {
            GoRouter.of(context).go("/login/credentials");
          },
          onResend: () {},
          controller: TextEditingController(),
        ),
      ),
    ),
    GoRoute(
      path: "/password-reset/new-password/:authorizationCode",
      builder: (context, state) => AuthFlowPage(
        child: NewPasswordFormView(
          method: PasswordResetMethod.withAuthorizationCode,
          authorizationCode: state.params["authorizationCode"],
          onDone: () => GoRouter.of(context).go("/password-reset/login"),
        ),
      ),
    ),
    GoRoute(
      path: "/password-reset/login",
      builder: (context, state) => AuthFlowPage(
        child: LoginFormView(
          onDone: (value) => GoRouter.of(context).go("/"),
          onResetPasswordPress: () => GoRouter.of(context).go("/password-reset"),
        ),
      ),
    ),
  ],
);

ShellRoute changePasswordFlowShellRoute = ShellRoute(
  builder: (context, state, child) => child,
  routes: [
    GoRoute(
      path: "/change-password/two-factor-auth",
      builder: (context, state) => AuthFlowPage(
        child: OtpView(
          email: state.queryParams["email"],
          mobile: state.queryParams["mobile"],
          obfuscateMobile: false,
          onDone: (result) => GoRouter.of(context).go(
            "/change-password/new-password/${result.authorizationCode}",
          ),
          onCancel: () {
            GoRouter.of(context).go("/login/credentials");
          },
          onResend: () {},
          controller: TextEditingController(),
        ),
      ),
    ),
    GoRoute(
      path: "/change-password/new-password/:authorizationCode",
      builder: (context, state) => AuthFlowPage(
        child: NewPasswordFormView(
          method: PasswordResetMethod.withAuthorizationCode,
          authorizationCode: state.params["authorizationCode"],
          onDone: () => GoRouter.of(context).go("/change-password/login"),
        ),
      ),
    ),
    GoRoute(
      path: "/change-password/login",
      builder: (context, state) => AuthFlowPage(
        child: LoginFormView(
          onDone: (value) => GoRouter.of(context).go("/"),
          onResetPasswordPress: () => GoRouter.of(context).go("/password-reset"),
        ),
      ),
    ),
  ],
);

GlobalKey<NavigatorState> navigatorKey = GlobalKey();
GoRouter baseRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",

  routes: [
    /// User Login Flow
    loginFlowShellRoute,

    /// User Reset Password Flow
    passwordResetFlowShellRoute,

    /// User Change Password Flow
    changePasswordFlowShellRoute,

    GoRoute(path: "/", redirect: (context, state) => "/splash"),

    GoRoute(
      path: "/splash",
      builder: (context, state) =>
          SplashView(onDone: (hasSession) => hasSession ? context.go("/home") : context.go("/login")),
    ),

    GoRoute(
      path: "/walkthrough",
      builder: (context, state) => SplashWalkthrough(
        onDone: () async => context.go("/"),
      ),
    ),

    ShellRoute(
      builder: (context, state, child) => Home(child: child),
      routes: [
        GoRoute(
          path: "/home",
          builder: (context, state) => const Dashboard(),
        ),
        GoRoute(
          path: "/my_profile",
          builder: (context, state) =>
              ProfileView(onDone: (result) => GoRouter.of(context).go("/change-password/two-factor-auth")),
        ),
        GoRoute(
          path: "/view-orders",
          builder: (context, state) => const OrderViewLauncher(),
        ),
        GoRoute(
          path: "/view-sales-orders",
          builder: (context, state) => const SalesOrderView(),
        ),
        GoRoute(
          path: "/view-recent-payments",
          builder: (context, state) => const RecentPaymentsView(),
        ),
        GoRoute(
          path: "/view-recent-sales-orders",
          builder: (context, state) => const RecentSalesOrderView(),
        ),
        GoRoute(
          path: "/view-recent-deliveries",
          builder: (context, state) => const RecentDeliveriesView(),
        ),
        GoRoute(
          path: "/view-pending-delivered-orders",
          builder: (context, state) => const PendingDeliveredOrderView(),
        ),
        GoRoute(
          path: "/view-latest-block-sales-orders",
          builder: (context, state) => const LatestBlockSalesOrdersView(),
        ),
        GoRoute(
          path: "/view-active-user-list",
          builder: (context, state) => const ActiveUserListView(),
        ),
        GoRoute(
          path: "/view-last-invoice-list",
          builder: (context, state) => const LatestInvoiceListView(),
        ),
        GoRoute(
          path: "/view-last-delivery-list",
          builder: (context, state) => const LastDeliveryListView(),
        ),
        GoRoute(
          path: "/view-assigned-truck-list",
          builder: (context, state) => const AssignedTruckListView(),
        ),
        GoRoute(
          path: "/order-submission-view",
          builder: (context, state) => OrderSubmissionView(
            selectedProducts: const [],
            controller: OrderCreateFormController(),
            simulateSalesOrderResponses: null,
          ),
        ),
        GoRoute(
          path: "/request-to-unlock-order-view",
          builder: (context, state) => const RequestToUnblockOrderView(salesOrderNumber: '', requestReferenceCode:'', outstandingAmount: '',),
        ),
        GoRoute(
          path: "/submit-payment-plan-view",
          builder: (context, state) => const SubmitPaymentPlanView(outstandingAmount: '', requestReferenceCode: '',),
        ),
        GoRoute(
          path: "/upload-payment-confirmation-view",
          builder: (context, state) => const UploadPaymentConfirmationView(salesOrderNumber: '',requestReferenceCode: ''),
        ),
        GoRoute(
          path: "/order-retail-credit-view",
          builder: (context, state) => OrderCreateRetailCreditView(controller: OrderCreateFormController()),
        ),
        GoRoute(
          path: "/delivery-order-creation-view",
          builder: (context, state) => DeliveryOrderCreationDeliveredView(),
        ),
        GoRoute(
          path: "/delivery-order-submission-view",
          builder: (context, state) => const DeliveryOrderSubmissionView(),
        ),
        GoRoute(
          path: "/delivery-order-view",
          builder: (context, state) => const DeliveryOrderView(),
        ),
        GoRoute(
          path: "/order-creation",
          builder: (context, state) => AvailableProduct(controller: OrderCreateFormController()),
        ),
        GoRoute(
          path: "/view-last-delivery",
          builder: (context, state) => const LastDeliveryView(),
        ),
        GoRoute(
          path: "/view-payments",
          builder: (context, state) => const ViewPayments(),
        ),
        GoRoute(
          path: "/view-reports-filter",
          builder: (context, state) => SearchFilterSalesOrderView(controller: ReportFormController()),
        ),
        GoRoute(
          path: "/view-reports",
          builder: (context, state) => ReportView(controller: ReportFormController()),
        ),
      ],
    ),

    /// Dev Routes
    ShellRoute(
      builder: (context, state, child) => Showcase(page: child),
      routes: [
        GoRoute(path: "/form", builder: (context, state) => TestFormPage()),
        GoRoute(path: "/widgets", builder: (context, state) => const WidgetCatalog()),
        GoRoute(path: "/typography", builder: (context, state) => const TypographyCatalog()),
        GoRoute(path: "/repo-test", builder: (context, state) => const MyHomePage()),
      ],
    ),
  ],
);
