import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/stations_data.dart';
import '../models/station.dart';
import '../providers/navigation_provider.dart';
import '../utils/responsive_helper.dart';
import 'ar_navigation_screen.dart';
import 'model_test_screen.dart';

class StationSelectionScreen extends StatefulWidget {
  const StationSelectionScreen({super.key});

  @override
  State<StationSelectionScreen> createState() => _StationSelectionScreenState();
}

class _StationSelectionScreenState extends State<StationSelectionScreen> {
  String _searchQuery = '';
  List<Station> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    _filteredStations = StationsData.getActiveStations();
  }

  void _filterStations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredStations = StationsData.getActiveStations();
      } else {
        _filteredStations = StationsData.getActiveStations()
            .where((station) =>
                station.name.toLowerCase().contains(query.toLowerCase()) ||
                station.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectStation(Station station) {
    context.read<NavigationProvider>().selectStation(station);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ARNavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Station'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ModelTestScreen(),
                ),
              );
            },
            icon: const Icon(Icons.view_in_ar),
            tooltip: 'Test 3D Models',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5),
                  offset: Offset(0, ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5)),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Welcome to WondaGO Map!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18, tabletSize: 20, desktopSize: 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                Text(
                  'Choose a station to navigate to using AR',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 16, desktopSpacing: 20)),
                TextField(
                  onChanged: _filterStations,
                  decoration: InputDecoration(
                    hintText: 'Search stations...',
                    prefixIcon: Icon(Icons.search, color: const Color(0xFF2E7D32), size: ResponsiveHelper.getIconSize(context, 20, tabletSize: 22, desktopSize: 24)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 20, tabletSpacing: 25, desktopSpacing: 30)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(horizontal: 16, vertical: 12), tabletPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), desktopPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredStations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No stations available'
                              : 'No stations found for "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
                    itemCount: _filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = _filteredStations[index];
                      return _buildStationCard(station);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(Station station) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 12, desktopSpacing: 16)),
      elevation: ResponsiveHelper.getCardElevation(context, 2, tabletElevation: 3, desktopElevation: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 10, tabletSpacing: 12, desktopSpacing: 15)),
      ),
      child: InkWell(
        onTap: () => _selectStation(station),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 10, tabletSpacing: 12, desktopSpacing: 15)),
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
          child: Row(
            children: [
              Container(
                width: ResponsiveHelper.getResponsiveWidth(context, 40, tabletWidth: 50, desktopWidth: 60),
                height: ResponsiveHelper.getResponsiveHeight(context, 40, tabletHeight: 50, desktopHeight: 60),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 20, tabletSpacing: 25, desktopSpacing: 30)),
                ),
                child: Center(
                  child: Text(
                    station.id.toString(),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16, tabletSize: 18, desktopSize: 20),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 16, desktopSpacing: 20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                    Text(
                      station.briefDescription,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: ResponsiveHelper.getIconSize(context, 14, tabletSize: 16, desktopSize: 18),
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                        Expanded(
                          child: Text(
                            '${station.latitude.toStringAsFixed(6)}, ${station.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10, tabletSize: 12, desktopSize: 14),
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF2E7D32),
                size: ResponsiveHelper.getIconSize(context, 14, tabletSize: 16, desktopSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
