import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const SearchingScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => const PermissionScreen(),
        '/third':(context) => const BluetoothScreen(),
        '/four':(context) => const ConnectedScreen(),
        '/five':(context) => const ListeningScreen(),
        '/six':(context) => const WorkingScreen(),
      },
    ),
  );
}

class SearchingScreen extends StatelessWidget {
  const SearchingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xf5747474),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
            ),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                // We could also use the is icon maybe. It's for searching.
                // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                icon: const Icon(Icons.wifi,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/second');
                },
              ),
            ),
              const Text('Searching for Sight++ Location', textAlign: TextAlign.center,
                  style: TextStyle(color:Colors.white,fontSize:30.0)),
          ],
        ),
      ),
    );
  }
}

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xf5747474),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
            ),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.priority_high_outlined,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/third');
                },
              ),
            ),
            // Add Margin to push word inwards
            const Text('Necessary Permissions Not Given', textAlign: TextAlign.center,
                style: TextStyle(color:Colors.white,fontSize:24.0)),
          ],
        ),
      ),
    );
  }
}


class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff232981),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            const Text('Connected', style: TextStyle(color:Colors.white,fontSize:30.0),  textAlign: TextAlign.center),

            const Text('Searching For Bluetooth Beacon', style: TextStyle(color:Colors.white,fontSize:30.0),  textAlign: TextAlign.center),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/four');
                },
              ),
            ),
            const Text('Hold To Record',textAlign: TextAlign.center,
                style: TextStyle(color:Colors.white,fontSize:24.0)),
          ],
        ),
      ),
    );
  }
}


class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff1e90ff),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              child: const Text('Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
            ),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                // We could also use the is icon maybe. It's for searching.
                // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                icon: const Icon(Icons.mic,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/five');
                },
              ),
            ),
            const Text('Hold To Record', textAlign: TextAlign.center,
                style: TextStyle(color:Colors.white,fontSize:30.0)),
          ],
        ),
      ),
    );
  }
}


class ListeningScreen extends StatelessWidget {
  const ListeningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xffb61316),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              child: const Text('Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
            ),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                // We could also use the is icon maybe. It's for searching.
                // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                icon: const Icon(Icons.mic,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/six');
                },
              ),
            ),
            const Text('Listening', textAlign: TextAlign.center,
                style: TextStyle(color:Colors.white,fontSize:30.0)),
          ],
        ),
      ),
    );
  }
}


class WorkingScreen extends StatelessWidget {
  const WorkingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff1e90ff),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            Container(
              child: const Text('Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
            ),
            Container(
              width:250,
              height: 250,
              decoration: const BoxDecoration(
                color:Color(0xff0b7ae6),
                borderRadius:BorderRadius.all(Radius.circular(120.0)),
              ),
              child: IconButton(
                // We could also use the is icon maybe. It's for searching.
                // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                icon: const Icon(Icons.mic,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/');
                },
              ),
            ),
            const Text('Working', textAlign: TextAlign.center,
                style: TextStyle(color:Colors.white,fontSize:30.0)),
          ],
        ),
      ),
    );
  }
}