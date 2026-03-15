import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsLiveMapScreen extends StatefulWidget {
  final String activeRaceId; // El "room" o evento que estamos mirando

  const EventsLiveMapScreen({super.key, required this.activeRaceId});

  @override
  State<EventsLiveMapScreen> createState() => _EventsLiveMapScreenState();
}

class _EventsLiveMapScreenState extends State<EventsLiveMapScreen> {
  final MapController _mapController = MapController();

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Ojo de Dios: Rastreo en Vivo', style: TextStyle(color: Colors.greenAccent)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text('CARRERA ID: ${widget.activeRaceId}', style: const TextStyle(color: Colors.white54)),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('races')
            .doc(widget.activeRaceId)
            .collection('runner_locations')
            .snapshots(),
        builder: (context, snapshot) {
          
          List<Marker> runnerMarkers = [];
          List<DocumentSnapshot> docs = [];

          if (snapshot.hasData) {
            docs = snapshot.data!.docs;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['latitude'] != null && data['longitude'] != null) {
                runnerMarkers.add(
                  Marker(
                    point: LatLng(data['latitude'], data['longitude']),
                    width: 60,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data['displayName'] ?? 'Runner', 
                            style: const TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                        Icon(
                          Icons.location_on, 
                          color: (data['speed'] ?? 0) > 0.5 ? Colors.greenAccent : Colors.orangeAccent, 
                          size: 30
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          }

          // AQUÍ EMPIEZA EL STACK DEL PUNTO 2
          return Stack(
            children: [
              // Capa 1: El Mapa
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(19.4326, -99.1332), 
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.codemakesoft.smartsync',
                  ),
                  MarkerLayer(markers: runnerMarkers),
                ],
              ),

              // Capa 2: Panel Flotante a la derecha
              Positioned(
                right: 20,
                top: 20,
                bottom: 20,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "RADAR: ${docs.length} ACTIVOS", 
                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.person, size: 16, color: Colors.white),
                              ),
                              title: Text(data['displayName'] ?? 'Anónimo', 
                                         style: const TextStyle(color: Colors.white, fontSize: 13)),
                              subtitle: Text("${data['speed']?.toStringAsFixed(1) ?? '0'} km/h",
                                            style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              onTap: () {
                                // Al tocar el nombre, el mapa vuela hacia el corredor
                                _mapController.move(
                                  LatLng(data['latitude'], data['longitude']), 
                                  16.0
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
