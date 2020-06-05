import 'dart:io' show Platform;
import 'package:masterplan/models/transaction.dart';
import 'package:masterplan/widgets/Monatsplan/transaction_list.dart';
import 'package:masterplan/widgets/monatsplan/chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottom_sheet_fix.dart';
import 'new_transactions.dart';

class MonatsPlan extends StatefulWidget {
final String categoryId;
final String categoryTitle;

MonatsPlan(this.categoryId,this.categoryTitle);

  @override
  _MyMonatsPlanState createState() => _MyMonatsPlanState();
}

class _MyMonatsPlanState extends State<MonatsPlan> {
  final List<Transaction> _userTransactions = [
    /* Transaction(
      id: 't1',
      iniz: 'Beispiel',
      name: 'Max Musterdödel',
      eht: 500,
      stufe: 2,
      gp: 45,
      date: DateTime.now(),
    ), */
  ];

  bool _showChart = false;

  Function addTX;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
    String txiniz,
    String txname,
    int txstufe,
    int txeht,
    int txgp,
  ) {
    final newTX = Transaction(
      iniz: txiniz,
      name: txname,
      eht: txeht,
      stufe: txstufe,
      gp: txgp,
      date: DateTime.now(),
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTX);
    });
  }

  void _showSignupModalSheet() {
    showModalBottomSheetApp(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: GestureDetector(
                onTap: () {},
                child: NewTransaction(_addNewTransaction),
                behavior: HitTestBehavior.opaque),
          );
        });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(MediaQueryData mediaQuery,
      PreferredSizeWidget appBar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Summen anzeigen', style: Theme.of(context).textTheme.subtitle1),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.84,
              child: Chart(_recentTransactions))
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery,
      PreferredSizeWidget appBar, Widget txListWidget) {
    return [
      Container(
          color: Color.fromRGBO(225, 253, 248, 1),
          height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
              0.2,
          child: Chart(_recentTransactions)),
      txListWidget
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
                final PreferredSizeWidget appBar = Platform.isIOS
                    ? CupertinoNavigationBar(
                        backgroundColor: Colors.cyan[800],
                       middle: Text(categoryTitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                  ),
                  onTap: () => _showSignupModalSheet(),
                ),
              ],
            ),
          )
        : AppBar(
            backgroundColor: Colors.cyan[800],
            title: Text(categoryTitle),);
    final txListWidget = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.84,
        child: TransactionList(_userTransactions, _deleteTransaction));

    final pageBody = SingleChildScrollView(
      child: Container(
        color: Color.fromRGBO(225, 253, 248, 1),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(mediaQuery, appBar, txListWidget),
            if (!isLandscape)
              ..._buildPortraitContent(mediaQuery, appBar, txListWidget),
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    backgroundColor: Colors.cyan[600],
                    child: Icon(Icons.add),
                    onPressed: () => _showSignupModalSheet(),
                  ));
  }
}
