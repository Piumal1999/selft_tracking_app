import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:selftrackingapp/app_localizations.dart';
import 'package:selftrackingapp/models/location.dart';
import 'package:selftrackingapp/models/reported_case.dart';
import 'package:selftrackingapp/networking/data_repository.dart';
import 'package:selftrackingapp/utils/tracker_colors.dart';
import 'package:selftrackingapp/widgets/case_item.dart';

class CaseListScreen extends StatefulWidget {
  @override
  _CaseListScreenState createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  String _searchKey = "";
  List<ReportedCase> _cases = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            floating: true,
            snap: true,
            expandedHeight: 100.0,
            flexibleSpace: Container(
              margin: const EdgeInsets.all(20.0),
              child: TextFormField(
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: TrackerColors.primaryColor),
                  labelText: AppLocalizations.of(context)
                      .translate("case_screen_search"),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: TrackerColors.primaryColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: TrackerColors.primaryColor, width: 1.0),
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: TrackerColors.primaryColor,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchKey = value;
                  });
                },
              ),
            ),
          ),
          FutureBuilder(
            future: GetIt.instance<DataRepository>().fetchCases(
                AppLocalizations.of(context).locale.toString().split("_")[0]),
            builder: (BuildContext context,
                AsyncSnapshot<List<ReportedCase>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return SliverToBoxAdapter(
                    child: Center(
                        child:
                            Text("Error getting the cases, try again later.")),
                  );
                  break;
                case ConnectionState.waiting:
                  return SliverToBoxAdapter(
                    child: Container(
                        child: Center(child: CircularProgressIndicator()),
                        padding: const EdgeInsets.all(30.0)),
                  );
                  break;
                case ConnectionState.active:
                  return SliverToBoxAdapter(
                    child: Center(
                        child:
                            Text("Error getting the cases, try again later.")),
                  );
                  break;
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    _cases = snapshot.data
                        .where((_) => _.locations
                            .where((location) => location.address
                                .toLowerCase()
                                .contains(_searchKey.toLowerCase()))
                            .isNotEmpty)
                        .toList();
                    if (_cases.length > 0) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          return CaseItem(_cases[index]);
                        }, childCount: _cases.length),
                      );
                    } else {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Center(
                              child: Text("No cases found for that search.")),
                        ),
                      );
                    }
                  } else {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(
                            child: Text("No cases found for that search.")),
                      ),
                    );
                  }
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  // _changeTab(int tab) {
  //   setState(() {
  //     // _selectedTab = tab;
  //   });
  // }
}
