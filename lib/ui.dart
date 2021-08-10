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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(100, 73, 73, 73),
      appBar: AppBar(
        title: const Text('First Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children:[
            const Text('Not connected', style: TextStyle(color:Colors.white,fontSize:18.0)),
            Container(
              width:200,
              height: 200,
              decoration: const BoxDecoration(
                color:Colors.blue,
                borderRadius:BorderRadius.all(Radius.circular(10.0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.wifi,size:150,color: Colors.white,),
                // Within the `FirstScreen` widget
                onPressed: () {
                  // Navigate to the second screen using a named route.
                  Navigator.pushNamed(context, '/second');
                },
              ),
            ),
            const Text('Searching for Sight++ Location ...',style: TextStyle(color:Colors.white,fontSize:18.0)),
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