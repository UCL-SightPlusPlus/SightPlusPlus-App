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
        '/': (context) => const FirstScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => const SecondScreen(),
      },
    ),
  );
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  final _isConnected = '';


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
                color:Color(0xe21e90ff),
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

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(100, 35, 41, 129),
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            const Text('Connected, Searching for Bluetooth Beacon ...', style: TextStyle(color:Colors.white,fontSize:18.0)),
            Container(
              width:200,
              height: 200,
              decoration: const BoxDecoration(
                color:Colors.blue,
                borderRadius:BorderRadius.all(Radius.circular(80.0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/second');
                },
              ),
            ),
            const Text('Hold To Record',style: TextStyle(color:Colors.white,fontSize:18.0)),
          ],
        ),
      ),
    );
  }
}