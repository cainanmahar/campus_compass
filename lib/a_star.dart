import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';

Map<int, Node> nodes = {};

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

          if (node1Id is int && node2Id is int && distance is double) {
            Node? node1 = nodes[node1Id];
            Node? node2 = nodes[node2Id];

            if (node1 != null && node2 != null) {
              node1.addNeighbor(node2, distance);
              node2.addNeighbor(node1, distance);
            }
          }
        }
      }
    }
  }
}

// node class that represents each waypoint in the graph
class Node {
  LatLng coords;

  // map to hold neigbors and their edge weights
  Map<Node, double> neighbors;

  // our cost values
  // gCost = cost of the path from start node to the current node
  // hCost = cost of the heuristic estimate
  // fCost = gCost + hCost, used to evaluate which node to explore next
  double gCost, hCost, fCost;
  // parent node for path reconstruction
  Node? parent;

  // constructor to initialize the node
  Node(double lat, double lng)
      : neighbors = {},
        gCost = double.infinity,
        hCost = double.infinity,
        fCost = double.infinity,
        parent = null,
        coords = LatLng(lat, lng);

  // method to add a neighbnor and its edge weight to this node
  void addNeighbor(Node neighborNode, [double weight = 1]) {
    neighbors[neighborNode] = weight;
  }
}

// our heuristic to estimate the cost from a node to the goal
double heuristic(Node node, Node goal) {
  // currently manhattan distance
  const distCalc = DistanceVincenty(roundResult: false);
  return distCalc.as(LengthUnit.Meter, node.coords, goal.coords);
}

// our A* implementation
List<Node>? aStarSearch(int startID, int goalID) {
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
    for (var neighbor in current.neighbors.keys) {
      // skip if already evaluated
      if (closedSet.contains(neighbor)) continue;

      // calc the tentative gCost for the neighbor
      var tentativeGScore = current.gCost + current.neighbors[neighbor]!;

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
  // return noul if no path is found
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
