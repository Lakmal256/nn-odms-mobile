import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class LoadingIndicatorController extends ValueNotifier<bool> {
  LoadingIndicatorController() : super(false);

  void show() {
    value = true;
    notifyListeners();
  }

  void hide() {
    value = false;
    notifyListeners();
  }
}

class LoadingIndicatorPopup extends StatelessWidget {
  const LoadingIndicatorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class ConnectivityIndicator extends StatelessWidget {
  ConnectivityIndicator({Key? key}) : super(key: key);

  final Connectivity _connectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityResult.none) {
          return Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.black.withOpacity(0.5),
            child: const Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Please check your connection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
