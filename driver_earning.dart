import 'package:flutter/material.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.today, color: Colors.deepPurple),
                title: Text('Today\'s Earnings'),
                subtitle: Text('₹1200'),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: Text('Weekly Earnings'),
                subtitle: Text('₹8400'),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.account_balance, color: Colors.deepPurple),
                title: Text('Total Earnings'),
                subtitle: Text('₹36000'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
