import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dio JSONPlaceholder Example'),
        ),
        body: DataFetchingWidget(),
      ),
    );
  }
}

class DataFetchingWidget extends StatefulWidget {
  @override
  _DataFetchingWidgetState createState() => _DataFetchingWidgetState();
}

class _DataFetchingWidgetState extends State<DataFetchingWidget> {
  List<Map<String, dynamic>> dataList = [];
  int currentPage = 1;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDataFromJSONPlaceholder();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> fetchDataFromJSONPlaceholder() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final dio = Dio();
    final baseUrl = "https://jsonplaceholder.typicode.com";

    try {
      final response =
          await dio.get("$baseUrl/posts?_page=$currentPage&_limit=10");

      if (response.statusCode == 200) {
        // Data has been successfully fetched
        List<dynamic> data = response.data;

        for (var item in data) {
          int id = item['id'];
          String title = item['title'];
          String body = item['body'];

          // Create a map for each item
          Map<String, dynamic> itemData = {
            'id': id,
            'title': title,
            'body': body,
          };

          // Add the item data to the list
          dataList.add(itemData);
        }
        // Update the UI after data is fetched
        setState(() {});
      } else {
        // Handle any errors or status codes other than 200 here
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      // Handle any exceptions here
      print("Error: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      currentPage++;
      fetchDataFromJSONPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            controller: _scrollController, // Attach the scroll controller
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("ID: ${dataList[index]['id']}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Title: ${dataList[index]['title']}"),
                    Text("Body: ${dataList[index]['body']}"),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
