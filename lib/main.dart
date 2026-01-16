import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseHome(),
    );
  }
}

class ExpenseHome extends StatefulWidget {
  @override
  _ExpenseHomeState createState() => _ExpenseHomeState();
}

class _ExpenseHomeState extends State<ExpenseHome> {
  List<Map<String, dynamic>> items = [
    {"desc": "", "amount": ""}
  ];

  @override
  void initState() {
    super.initState();
    _loadData(); // App চালু হলে ডাটা লোড হবে
  }

  // ডাটা ফোনের মেমোরিতে সেভ করার ফাংশন
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(items);
    await prefs.setString('expense_data', encodedData);
  }

  // ফোন থেকে সেভ করা ডাটা ফিরিয়ে আনার ফাংশন
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('expense_data');
    if (savedData != null) {
      setState(() {
        items = List<Map<String, dynamic>>.from(jsonDecode(savedData));
      });
    }
  }

  // মোট টাকা হিসাব করার ফাংশn
  double get totalAmount {
    double total = 0;
    for (var item in items) {
      total += double.tryParse(item['amount'].toString()) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            children: [
              // Total Amount Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Total Amount is : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF001F3F), width: 2),
                    ),
                    child: Text(
                      totalAmount.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Input Boxes
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        children: [
                          // Description Input
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF001F3F), width: 2),
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                                decoration: const InputDecoration(
                                  hintText: "Write Description",
                                  hintStyle: TextStyle(color: Colors.red),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  items[index]['desc'] = value;
                                  _saveData(); // টাইপ করার সাথে সাথে সেভ হবে
                                  setState(() {});
                                },
                                controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                    text: items[index]['desc'],
                                    selection: TextSelection.collapsed(offset: items[index]['desc'].length),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Amount Input
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF001F3F), width: 2),
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.red),
                                decoration: const InputDecoration(
                                  hintText: "Amount",
                                  hintStyle: TextStyle(color: Colors.red),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  items[index]['amount'] = value;
                                  _saveData(); // টাইপ করার সাথে সাথে সেভ হবে
                                  setState(() {});
                                },
                                controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                    text: items[index]['amount'].toString(),
                                    selection: TextSelection.collapsed(offset: items[index]['amount'].toString().length),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            items.add({"desc": "", "amount": ""});
            _saveData();
          });
        },
        backgroundColor: const Color(0xFF4A4E54),
        child: const Icon(Icons.add, size: 35, color: Colors.white),
        shape: const CircleBorder(),
      ),
    );
  }
}