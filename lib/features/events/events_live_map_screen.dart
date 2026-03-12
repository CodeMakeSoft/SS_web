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
      
      // EL RADAR EN VIVO 
      body: StreamBuilder<QuerySnapshot>(
        // Buscamos a TODOS los usuarios dentro de esta carrera particular en Firestore
        stream: FirebaseFirestore.instance
            .collection('races')
            .doc(widget.activeRaceId)
            .collection('runner_locations') // La subcolección que creaste en el móvil
            .snapshots(),
            
        builder: (context, snapshot) {
          
          List<Marker> runnerMarkers = [];

          // Si hay datos recibidos (alguien corriendo hoy)
          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              // Firebase nos mandó un 'ultimo punto conocido'
              if (data['latitude'] != null && data['longitude'] != null) {
                
                runnerMarkers.add(
                  Marker(
                    point: LatLng(data['latitude'], data['longitude']),
                    width: 40,
                    height: 40,
                    child: Tooltip( // Al pasar el mouse encima de la mosca...
                      message: 'Corredor: ${doc.id}',
                      child: const Icon(Icons.run_circle, color: Colors.blueAccent, size: 30),
                    ),
                  ),
                );
              }
            }
          }

          // Pintamos el Mapa Crudo
          return FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(19.4326, -99.1332), // Empieza en CDMX o donde quieras
              initialZoom: 13.0,
            ),
            children: [
              // 1. La capa gráfica tipo cartografía oscura (Dark Mode)
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.codemakesoft.smartsync',
              ),
              // 2. Los pinchitos de los corredores moviéndose solos
              MarkerLayer(markers: runnerMarkers),
            ],
          );
        },
      ),
    );
  }
}
