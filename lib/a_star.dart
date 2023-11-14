import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';

Map<int, Node> nodes = {};
Map<String, int> endpointLocations =
    {}; // global variable for endpoint locations

void initializeNodes() async {
  String contents = await rootBundle.loadString('assets/graph.json');
  var graphD = jsonDecode(contents);

  // Print the overall structure and type of the decoded JSON for debugging
  //print("Decoded JSON: $graphD");
  //print("Type of decoded JSON: ${graphD.runtimeType}");

  if (graphD is Map<String, dynamic>) {
    // Handling 'nodes'
    if (graphD['nodes'] is List) {
      //print("Type of nodes: ${graphD['nodes'].runtimeType}");

      for (var node in graphD['nodes']) {
        if (node is Map<String, dynamic>) {
          int? nodeId = node['id'];
          double? latitude = node['latitude'];
          double? longitude = node['longitude'];

          if (nodeId is int && latitude is double && longitude is double) {
            nodes[nodeId] = Node(latitude, longitude);
          }
        }
      }
    }

    // Handling 'edges'
    if (graphD['edges'] is List) {
      //print("Type of edges: ${graphD['edges'].runtimeType}");

      for (var edge in graphD['edges']) {
        if (edge is Map<String, dynamic>) {
          int? node1Id = edge['node_1'];
          int? node2Id = edge['node_2'];
          double? distance = edge['distance'];
          bool? ada = edge['ada'];

          if (node1Id is int &&
              node2Id is int &&
              distance is double &&
              ada is bool) {
            Node? node1 = nodes[node1Id];
            Node? node2 = nodes[node2Id];

            if (node1 != null && node2 != null) {
              Node.connect(node1, node2, Edge(distance, ada));
            }
          }
        }
      }
    }
  }
}

// New function to load and parse endpoints
// will need modifications once we get indoor nav graph
void loadEndpoints() async {
  String endpointContents =
      await rootBundle.loadString('assets/outdoor_endpoints.json');
  var endpointsJson = jsonDecode(endpointContents);

  if (endpointsJson is Map<String, dynamic>) {
    if (endpointsJson['outdoor_endpoints'] is List) {
      List<dynamic> endpointsList = endpointsJson['outdoor_endpoints'];
      for (var endpoint in endpointsList) {
        if (endpoint is Map<String, dynamic>) {
          String? location = endpoint['location'];
          int? nodeId = endpoint['node_id'];

          if (location != null && nodeId != null) {
            endpointLocations[location] = nodeId;
          }
        }
      }
    }
  }
}

// node class that represents each waypoint in the graph
class Node {
  LatLng coords;

  // Map of neighbors and their corresponding edge data
  Map<Node, Edge> connections;

  // our cost values
  // gCost = cost of the path from start node to the current node
  // hCost = cost of the heuristic estimate
  // fCost = gCost + hCost, used to evaluate which node to explore next
  double gCost, hCost, fCost;
  // parent node for path reconstruction
  Node? parent;

  // constructor to initialize the node
  Node(double lat, double lng)
      : connections = {},
        gCost = double.infinity,
        hCost = double.infinity,
        fCost = double.infinity,
        parent = null,
        coords = LatLng(lat, lng);

  void addNeighbor(Node other, Edge edge) {
    connections[other] = edge;
  }

  // Gets a list of the neighbors of this node, optionally filtered by neighbors
  // whose connection to this node is ada-compliant.
  Iterable<Node> getNeighbors({bool adaOnly = false}) {
    return connections.keys
        .where((neighbor) => !adaOnly || connections[neighbor]!.ada);
  }

  // method to connect two nodes together
  static void connect(Node a, Node b, Edge edge) {
    a.addNeighbor(b, edge);
    b.addNeighbor(a, edge);
  }
}

class Edge {
  double weight;
  bool ada;

  Edge(this.weight, this.ada);
}

// our heuristic to estimate the cost from a node to the goal
double heuristic(Node node, Node goal) {
  // currently manhattan distance
  const distCalc = DistanceVincenty(roundResult: false);
  return distCalc.as(LengthUnit.Meter, node.coords, goal.coords);
}

// our A* implementation
List<Node>? aStarSearch(int startID, int goalID, bool adaOnly) {
  Node start = nodes[startID]!;
  Node goal = nodes[goalID]!;
  // open set contains the nodes to be evaluated
  var openSet = <Node>{start};
  // closed set contains the nodes already evaluated
  var closedSet = <Node>{};

  // start node
  start.gCost = 0;
  start.hCost = heuristic(start, goal);
  start.fCost = start.hCost;

  // while nodes left to be explored
  while (openSet.isNotEmpty) {
    // find the node in openSet with the lowest fCost
    var current = openSet.reduce((a, b) => a.fCost < b.fCost ? a : b);

    // if we find current is our goal node, return the path of how we got there
    if (current == goal) {
      return reconstructPath(current, start);
    }

    // move the current node out of openSet to closedSet
    openSet.remove(current);
    closedSet.add(current);

    // explore neigbors of the current node
    for (var neighbor in current.getNeighbors(adaOnly: adaOnly)) {
      // skip if already evaluated
      if (closedSet.contains(neighbor)) continue;

      // calc the tentative gCost for the neighbor
      var tentativeGScore =
          current.gCost + current.connections[neighbor]!.weight;

      // discover new node
      if (!openSet.contains(neighbor)) {
        openSet.add(neighbor);
      } else if (tentativeGScore >= neighbor.gCost) {
        // continue if not a better path
        continue;
      }

      // update neigbor node costs and parent
      neighbor.parent = current;
      neighbor.gCost = tentativeGScore;
      neighbor.hCost = heuristic(neighbor, goal);
      neighbor.fCost = neighbor.gCost + neighbor.hCost;
    }
  }
  // return null if no path is found
  return null;
}

// reconstructs path from goal to the start
List<Node> reconstructPath(Node current, Node start) {
  // start the path with the goal node
  var path = <Node>[current];

  // trace back from goal to start
  while (current.parent != null && current != start) {
    current = current.parent!;
    path.add(current);
  }

  // return the path in the correct order
  return path.reversed.toList();
}
