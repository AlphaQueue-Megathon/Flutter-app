import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stellantis/Map/Utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

const timeToChargeOnePercent = 0, chargingWaitingTime = 0;

Future<List<Object>> unordered_path(List<LatLng> checkpoints,
    List<LatLng> chargingPoints, int initBattery) async {
  int n = checkpoints.length, m = chargingPoints.length;

  var dist = List.generate(n + m, (_) => List.filled(n + m, 0.0));
  for (int i = 0; i < n + m; i++) {
    for (int j = 0; j < n + m; j++) {
      if (i == j) continue;
      LatLng I = (i >= n) ? chargingPoints[i - n] : checkpoints[i];
      LatLng J = (j >= n) ? chargingPoints[j - n] : checkpoints[j];
      dist[i][j] = await (distanceBetween(I, J));
      // dist[i][j] = dist[i][j] / 2;
    }
  }

  // [bitmask of checkpoints, bit is 1 if yet to be visited][current checkpoint or charging station][current battery]
  const int Infinity = 1000000000;
  var dp = List.generate((1 << n),
      (_) => List.generate(n + m, (__) => List.filled(101, Infinity)));
  // [new bm, new current pos, new remaining battery] or [-1] to indicate staying at the same CS and +1 the battery
  var moveTo = List.generate((1 << n),
      (_) => List.generate(n + m, (__) => List.filled(101, [-1, -1, -1])));

  print("DIst: ");
  print(dist);

  for (int i = 0; i <= 100; i++) {
    dp[0][n - 1][i] = 0;
  }

  for (int bm = 1; bm < (1 << n); bm++) {
    // console.log("Solving for bitmask", bm);
    print("Solving for bitmask ");
    print(bm);

    // Only iterate over lastPos which is either a visited checkpoint or a CS
    for (int lastPosIdx = n + m - 1; lastPosIdx >= 0; lastPosIdx--) {
      if (!(lastPosIdx >= n || (bm & (1 << lastPosIdx)) == 0)) continue;

      LatLng lastPos = lastPosIdx < n
          ? checkpoints[lastPosIdx]
          : chargingPoints[lastPosIdx - n];

      // console.log("on lastPos", lastPosIdx);
      print("on lastPos ");
      print(lastPosIdx);

      for (int battery = 100; battery >= 0; battery--) {
        // Try to move to an (unvisited) checkpoint. Doesn't matter if lastPos was a checkpoint or a CS.
        for (int nextCheck = 0; nextCheck < n; nextCheck++) {
          if ((bm & (1 << nextCheck)) == 0) continue;

          int batteryTaken = dist[lastPosIdx][nextCheck].ceil();
          // await batteryUsed(lastPos, checkpoints[nextCheck]);
          int timeRequired = dist[lastPosIdx][nextCheck].ceil();

          if (batteryTaken > battery) continue;

          int newBm = bm - (1 << nextCheck);
          int dpChoice =
              dp[newBm][nextCheck][battery - batteryTaken] + timeRequired;
          print("!!!");
          if (dpChoice < dp[bm][lastPosIdx][battery]) {
            dp[bm][lastPosIdx][battery] = dpChoice;
            moveTo[bm][lastPosIdx]
                [battery] = [newBm, nextCheck, battery - batteryTaken];
          }
        }

        // Try to move to a CS, only if lastPos wasn't a CS
        if (lastPosIdx < n) {
          for (int nextCharging = n; nextCharging < n + m; nextCharging++) {
            int batteryTaken = dist[lastPosIdx][nextCharging].ceil();
            // await batteryUsed(lastPos, chargingPoints[nextCharging - n]);
            int timeRequired = dist[lastPosIdx][nextCharging].ceil();
            // await timeTaken(lastPos, chargingPoints[nextCharging - n]) + chargingWaitingTime;

            if (batteryTaken > battery) continue;

            int dpChoice =
                dp[bm][nextCharging][battery - batteryTaken] + timeRequired;

            if (dpChoice < dp[bm][lastPosIdx][battery]) {
              dp[bm][lastPosIdx][battery] = dpChoice;
              moveTo[bm][lastPosIdx]
                  [battery] = [bm, nextCharging, battery - batteryTaken];
            }
          }
        } else if (battery < 100) {
          // If lastPos was a CS, try charging the car by 1% at the same position
          int dpChoice =
              dp[bm][lastPosIdx][battery + 1] + timeToChargeOnePercent;
          if (dpChoice < dp[bm][lastPosIdx][battery]) {
            dp[bm][lastPosIdx][battery] = dpChoice;
            moveTo[bm][lastPosIdx][battery] = [-1];
          }
        }
      }
    }
  }

  print("REconstructing path");
  // Reconstruct the path: [x, y] or [csx, csy, refill count]
  var path = [];
  var currState = [(1 << n) - 1 - 1, 0, initBattery];
  var isCharging = false;

  print("n");
  print(n);
  print("m");
  print(m);
  print("DP: ");
  for (int i = 1; i < (1 << n); i++) {
    break;
    for (int j = 0; j < n + m; j++) {
      for (int k = 0; k <= 100; k++) {
        if (dp[i][j][k] >= Infinity) continue;

        print(i);
        print(", ");
        print(j);
        print(", ");
        print(k);
        print(" = ");
        print(dp[i][j][k]);
        print("\n");
      }
    }
  }

  print("final answer found!!!");
  print(dp[(1 << n) - 1 - 1][0][initBattery]);

  while (true) {
    if (!isCharging) {
      path.add(currState[1] >= n
          ? chargingPoints[currState[1] - n]
          : checkpoints[currState[1]]);
    }
    isCharging = false;

    if (const IterableEquality().equals(
        moveTo[currState[0]][currState[1]][currState[2]], [-1, -1, -1])) break;

    if (moveTo[currState[0]][currState[1]][currState[2]].length == 1) {
      // stay at CS and charge
      currState[2]++;

      if (path[path.length - 1].length == 2) {
        path[path.length - 1].add(1);
      } else {
        path[path.length - 1][2]++;
      }

      isCharging = true;
    } else {
      currState = moveTo[currState[0]][currState[1]][currState[2]];
    }
  }

  print("Path");
  print(path);

  Fluttertoast.showToast(
      msg: "Minimum time: ${dp[(1 << n) - 1 - 1][0][initBattery]}",
      toastLength: Toast.LENGTH_SHORT);

  for (int i = 0; i < path.length; i++) {
    Fluttertoast.showToast(
        msg: path[i].toString(), toastLength: Toast.LENGTH_SHORT);
  }
  return [dp[(1 << n) - 1 - 1][0][initBattery], path];
}
