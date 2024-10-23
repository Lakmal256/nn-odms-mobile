import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odms/locator.dart';
import 'package:http/http.dart' as http;


class SalesOrderRepoTestValue {
  SalesOrderRepoTestValue({List<dynamic>? salesOrders}) : allSalesOrders = salesOrders ?? List.empty(growable: true);

  List<dynamic> allSalesOrders;

}

class SalesOrderTestRepo extends ValueNotifier<SalesOrderRepoTestValue> {
  SalesOrderTestRepo({SalesOrderRepoTestValue? value}) : super(value ?? SalesOrderRepoTestValue());

  void addSalesOrder(dynamic salesOrder) {
    value.allSalesOrders.add(salesOrder);
    notifyListeners();
  }

  void addAllSalesOrders(List<dynamic> salesOrders) {
    value.allSalesOrders.addAll(salesOrders);
    notifyListeners();
  }

  List<dynamic> filterByStatus(String status) {
    return value.allSalesOrders.where((element) => element["status"] == status).toList();
  }
}

class SalesOrderListView extends StatelessWidget {
  const SalesOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                TextButton(onPressed: (){
                  locate<SalesOrderTestRepo>().addSalesOrder({"status": "OPEN"});
                }, child: Text("Add data - Open")),
                TextButton(onPressed: (){
                  locate<SalesOrderTestRepo>().addSalesOrder({"status": "CLOSED"});
                }, child: Text("Add data - Closed")),
              ],
            ),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: locate<SalesOrderTestRepo>(),
                  builder: (context, value, _) {
                    return ListView.builder(
                        itemCount: value.allSalesOrders.length,
                        itemBuilder: (context, index) {
                          return Text(value.allSalesOrders[index].toString());
                        });
                  }),
            ),
            Expanded(
              child: AnimatedBuilder(
                  animation: locate<SalesOrderTestRepo>(),
                  builder: (context, _) {
                    final items = locate<SalesOrderTestRepo>().filterByStatus("CLOSED");
                    return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Text(items[index].toString());
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List categoryItemlist = [];

  Future getAllCategory() async {
    var baseUrl = "https://gssskhokhar.com/api/classes/";

    http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        categoryItemlist = jsonData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllCategory();
  }

  var dropdownvalue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DropDown List"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              hint: Text('hooseNumber'),
              items: categoryItemlist.map((item) {
                return DropdownMenuItem(
                  value: item['ClassCode'].toString(),
                  child: Text(item['ClassName'].toString()),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  dropdownvalue = newVal;
                });
              },
              value: dropdownvalue,
            ),
          ],
        ),
      ),
    );
  }
}
