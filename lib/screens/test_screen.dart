/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/01/2026
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test screen'), centerTitle: true),
      body: testListView(),
      //      testDismissible(3),
      // testDismissible(4),
    );
  }

  Widget testRow(int rownum) {
    return Row(
      children: [
        testText(rownum, "a"),
        //          VerticalDivider(width: 1, thickness: 1, color: Colors.black),
        testText(rownum, "b"),
        //          VerticalDivider(width: 1, thickness: 1, color: Colors.black),
        testText(rownum, "c"),
      ],
    );
  }

  //---------------------------------------------------------

  Widget testText(int rownum, String coltag) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.grey, width: 2.0)),
        ),
        child: Center(
          child: Text("Row $rownum$coltag", style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  //---------------------------------------------------------

  Widget testDismissible(int rownum) {
    return Dismissible(
      key: ValueKey(rownum),
      direction: DismissDirection.endToStart,
      // background: Container(
      //   color: Colors.red,
      //   alignment: Alignment.centerRight,
      //   padding: EdgeInsets.zero,
      //   child: const Icon(Icons.delete, color: Colors.white),
      // ),
      onDismissed: (direction) {
        deleteRound();
      },
      child: //Card(
      InkWell(
        child: testRow(rownum),
        //        onTap: () => _editRound(),
      ),
    );
  }

  //---------------------------------------------------------

  void deleteRound() {
    debugPrint("deleteRound");
  }

  //---------------------------------------------------------

  void editRound() {
    debugPrint("_editRound");
  }

  //---------------------------------------------------------

  Widget testListView2() {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        Widget? label;
        // if (match.useRoundLabels()) {
        //   label = rows[index].label != null
        //       ? roundLabelAvatar(rows[index].label ?? "", Colors.blue)
        //       : roundLabelAvatar("", Theme.of(context).colorScheme.surface);
        // }

        return Container(
          //          height: 60,
          key: Key("Row $index"),
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.green, width: 1.0)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: label,
            title: testDismissible(index),
          ),
        );
      },
    );
  }

  //---------------------------------------------------------

  Widget testListView() {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green, width: 1.0)),
      ),
      child: ListView(
        children: [
          testListTile(1),
          testListTile(2),
        ],
      ),
    );
  }
  //---------------------------------------------------------

  Widget testListTile(int rownum) {
    return ListTile(
                  contentPadding: EdgeInsets.zero,

      title: testDismissible(rownum));
  }
}
