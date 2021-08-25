import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    ScreenUtil.init(BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width
    ),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      // To avoid screen overflow when using keyboard
      resizeToAvoidBottomInset: false,
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff494949),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.end,
          children:[
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(0),ScreenUtil().setHeight(30),ScreenUtil().setWidth(0),ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color:Color(0xff333333),
                borderRadius:BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    //child: Icon(Icons.cancel,size: 50, color: Colors.white,),
                    child: Icon(Icons.check_circle,size: ScreenUtil().setWidth(50), color: Colors.white,semanticLabel: 'Permission is Given',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xffff1e39),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.wifi_off,size: ScreenUtil().setWidth(50), color: Colors.white,semanticLabel: 'Server is Not Connected',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xffff1e39),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.bluetooth_disabled,size: ScreenUtil().setWidth(50), color: Colors.white,semanticLabel: 'Bluetooth Beacon is Not Connected',),
                  ),
                ],
              ),
            ),

            MergeSemantics(
              child: Column(children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(100),
                      ScreenUtil().setWidth(10),
                      ScreenUtil().setHeight(50)),
                  width: double.infinity,
                  height: ScreenUtil().setHeight(350),
                  //decoration: const BoxDecoration(
                  //  color:Color(0xf5747474),
                  //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                  //),
                  child: IconButton(
                    // We could also use the is icon maybe. It's for searching.
                    // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                    icon:  Icon(Icons.wifi,size:350,color: Colors.white,semanticLabel: 'Searching for Sight++ Location, Please Move Closer to Rooms'),

                    // Within the `FirstScreen` widget
                    onPressed: () {
                      // Navigate to the second screen using a named route.
                      Navigator.pushNamed(context, '/second');
                    },
                  ),
                ),
                // Add Margin to push word inwards
                Semantics(
                  excludeSemantics: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(10),
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(40)),
                    child: Text('Searching for Sight++ Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(32))),
                  ),
                )
              ]),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(0),ScreenUtil().setHeight(0),ScreenUtil().setWidth(10),ScreenUtil().setHeight(10)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      excludeSemantics: true,
                      child:
                      Image(
                        image: AssetImage("images/intel_logo.png"),
                        height: ScreenUtil().setHeight(50),
                        width: ScreenUtil().setWidth(50),semanticLabel: 'Intel Logo',
                      ),
                    )
                  ]
              ),
            )
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
    ScreenUtil.init(
        BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff494949),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(30),
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.cancel,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Permission is Not Given',
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.wifi_off,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Server is Not Connected',
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xffff1e39),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.bluetooth_disabled,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Bluetooth Beacon is Not Connected',
                    ),
                  ),
                ],
              ),
            ),
            MergeSemantics(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(100),
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(50)),
                    width: double.infinity,
                    height: ScreenUtil().setHeight(350),
                    //decoration: const BoxDecoration(
                    //  color:Color(0xff0b7ae6),
                    //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                    //),
                    child: IconButton(
                      //icon: const Icon(Icons.priority_high_outlined,size:150,color: Colors.white,),
                      icon: const Icon(Icons.priority_high_outlined,
                          size: 350,
                          color: Colors.white,
                          semanticLabel:
                              'Necessary Permissions is Not Given, Please Give Permissions'),
                      // Within the `FirstScreen` widget
                      onPressed: () {
                        // Navigate to the second screen using a named route.
                        Navigator.pushNamed(context, '/third');
                      },
                    ),
                  ),
                  // Add Margin to push word inwards
                  Semantics(
                    excludeSemantics: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(40)),
                      child: Text('Necessary Permissions Not Given',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(32))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Image(
                      image: AssetImage("images/intel_logo.png"),
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(50),
                    ),
                  )
                ],
              ),
            )
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
    ScreenUtil.init(BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width
    ),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff232981),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.end,
          children:[
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(0),ScreenUtil().setHeight(30),ScreenUtil().setWidth(0),ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color:Color(0xff333333),
                borderRadius:BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    //child: Icon(Icons.cancel,size: 50, color: Colors.white,),
                    child: Icon(Icons.check_circle,size: 50, color: Colors.white,semanticLabel: 'Permission is Given',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.wifi,size: 50, color: Colors.white,semanticLabel: 'Server is Connected',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xffff1e39),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.bluetooth_disabled,size: 50, color: Colors.white,semanticLabel: 'Bluetooth Beacon is Not Connected',),
                  ),
                ],
              ),
            ),

            //const Text('Connected', style: TextStyle(color:Colors.white,fontSize:30.0),  textAlign: TextAlign.center),
            //const Text('Searching For Bluetooth Beacon', style: TextStyle(color:Colors.white,fontSize:30.0),  textAlign: TextAlign.center),
            Container(
              width:ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(100),
              color: Colors.white,
              //child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(80),
                    decoration: const BoxDecoration(
                      color:Colors.white,
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const TextField(
                       style:  TextStyle(fontSize: 32.0),
                       decoration: InputDecoration(
                          hintText: "Question Asked"
                      ),
                    ),
                  ),
                  Container(
                      width:ScreenUtil().setWidth(80),
                      height: ScreenUtil().setHeight(80),
                      decoration: const BoxDecoration(
                        color:Color(0xff0b7ae6),
                        borderRadius:BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Icon(Icons.search, color: Colors.white,semanticLabel: 'Question is Completed',)
                  ),
                ],
              ),
            ),
            MergeSemantics(
              child: Column(children: [
                Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(0), ScreenUtil().setWidth(10), ScreenUtil().setHeight(85)),
                  width: double.infinity,
                  height: ScreenUtil().setHeight(350),
                  //decoration: const BoxDecoration(
                  //  color:Color(0xff0b7ae6),
                  //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                  //),
                  child: IconButton(
                    icon: const Icon(Icons.mic,size:350,color: Colors.white,semanticLabel: 'Please Hold To Record Your Question'),
                    // Within the `FirstScreen` widget
                    onPressed: () {
                      // Navigate to the second screen using a named route.
                      Navigator.pushNamed(context, '/four');
                    },
                  ),
                ),
                // Add Margin to push word inwards
                Semantics(
                  excludeSemantics: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(10), ScreenUtil().setWidth(10), ScreenUtil().setHeight(40)),
                    child: Text('Hold To Record', textAlign: TextAlign.center,
                        style: TextStyle(color:Colors.white,fontSize:ScreenUtil().setSp(32))),
                  ),
                ),
              ],),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Image(
                      image: AssetImage("images/intel_logo.png"),
                      height: ScreenUtil().setHeight(50),
                      width: ScreenUtil().setWidth(50),
                    ),
                  )
                ],
              ),
            )
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
    ScreenUtil.init(BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width
    ),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff1e90ff),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.end,
          children:[
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(0),ScreenUtil().setHeight(30),ScreenUtil().setWidth(0),ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color:Color(0xff333333),
                borderRadius:BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    //child: Icon(Icons.cancel,size: 50, color: Colors.white,),
                    child: Icon(Icons.check_circle,size: 50, color: Colors.white,semanticLabel: 'Permission is Given',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.wifi,size: 50, color: Colors.white,semanticLabel: 'Server is Connected',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.bluetooth,size: 50, color: Colors.white,semanticLabel: 'Bluetooth Beacon is Connected',),
                  ),
                ],
              ),
            ),

            Container(
              width:ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(100),
              color: Colors.white,
              //child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(80),
                    decoration: const BoxDecoration(
                      color:Colors.white,
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const TextField(
                      style:  TextStyle(fontSize: 32.0),
                      decoration: InputDecoration(
                          hintText: "Question Asked"
                      ),
                    ),
                  ),
                  Container(
                      width:ScreenUtil().setWidth(80),
                      height: ScreenUtil().setHeight(80),
                      decoration: const BoxDecoration(
                        color:Color(0xff0b7ae6),
                        borderRadius:BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Icon(Icons.search, color: Colors.white,semanticLabel: 'Question is Completed',)
                  ),
                ],
              ),
            ),
            MergeSemantics(
              child: Column(children: [
                Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(0), ScreenUtil().setWidth(10), ScreenUtil().setHeight(85)),
                  width: double.infinity,
                  height: ScreenUtil().setHeight(350),
                  //decoration: const BoxDecoration(
                  //  color:Color(0xff0b7ae6),
                  //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                  //),
                  child: IconButton(
                    // We could also use the is icon maybe. It's for searching.
                    // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                    icon: const Icon(Icons.mic,size:350,color: Colors.white,semanticLabel: 'Please Hold To Record Your Question'),
                    // Within the `FirstScreen` widget
                    onPressed: () {
                      // Navigate to the second screen using a named route.
                      Navigator.pushNamed(context, '/five');
                    },
                  ),
                ),
                Semantics(
                  excludeSemantics: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(10), ScreenUtil().setWidth(10), ScreenUtil().setHeight(40)),
                    child: Text('Hold To Record', textAlign: TextAlign.center,
                        style: TextStyle(color:Colors.white,fontSize:ScreenUtil().setSp(32))),
                  ),
                )
              ],),
            ),

            // Add Margin to push word inwards

            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Semantics(
                  excludeSemantics: true,
                  child: Image(
                    image: AssetImage("images/intel_logo.png"),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(50),
                  ),
                ),
              ]),
            )
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
    ScreenUtil.init(
        BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xffb61316),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(30),
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xff0b7ae6),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    //child: Icon(Icons.cancel,size: 50, color: Colors.white,),
                    child: Icon(
                      Icons.check_circle,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Permission is Given',
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xff0b7ae6),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.wifi,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Server is Connected',
                    ),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color: Color(0xff0b7ae6),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(
                      Icons.bluetooth,
                      size: 50,
                      color: Colors.white,
                      semanticLabel: 'Bluetooth Beacon is Connected',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(100),
              color: Colors.white,
              //child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(80),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const TextField(
                      style: TextStyle(fontSize: 32.0),
                      decoration: InputDecoration(hintText: "Question Asked"),
                    ),
                  ),
                  Container(
                      width: ScreenUtil().setWidth(80),
                      height: ScreenUtil().setHeight(80),
                      decoration: const BoxDecoration(
                        color: Color(0xff0b7ae6),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        semanticLabel: 'Question is Completed',
                      )),
                ],
              ),
            ),
            MergeSemantics(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(0),
                        ScreenUtil().setWidth(10),
                        ScreenUtil().setHeight(85)),
                    width: double.infinity,
                    height: ScreenUtil().setHeight(350),
                    //decoration: const BoxDecoration(
                    //  color:Color(0xff0b7ae6),
                    //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                    //),
                    child: IconButton(
                      // We could also use the is icon maybe. It's for searching.
                      // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                      icon: const Icon(
                        Icons.mic,
                        size: 350,
                        color: Colors.white,
                        semanticLabel: 'Please Speak Your Question',
                      ),
                      // Within the `FirstScreen` widget
                      onPressed: () {
                        // Navigate to the second screen using a named route.
                        Navigator.pushNamed(context, '/six');
                      },
                    ),
                  ),
                  // Add Margin to push word inwards
                  Semantics(
                    excludeSemantics: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setWidth(10),
                          ScreenUtil().setHeight(40)),
                      child: Text('Listening',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(32))),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Semantics(
                  excludeSemantics: true,
                  child: Image(
                    image: AssetImage("images/intel_logo.png"),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(50),
                    semanticLabel: 'Intel Logo',
                  ),
                ),
              ]),
            )
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
    ScreenUtil.init(BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width
    ),
        designSize: const Size(412, 869),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // To go from Hex to ARGB just add '0xff' in front of the hex colour value.
      backgroundColor: const Color(0xff978d17),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.end,
          children:[
            Container(
              width: ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(120),
              margin:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(0),ScreenUtil().setHeight(30),ScreenUtil().setWidth(0),ScreenUtil().setHeight(30)),
              decoration: const BoxDecoration(
                color:Color(0xff333333),
                borderRadius:BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    //child: Icon(Icons.cancel,size: 50, color: Colors.white,),
                    child: Icon(Icons.check_circle,size: 50, color: Colors.white,semanticLabel: 'Permission is Given',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.wifi,size: 50, color: Colors.white,semanticLabel: 'Server is Connected',),
                  ),
                  Container(
                    width:ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                    decoration: const BoxDecoration(
                      color:Color(0xff0b7ae6),
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Icon(Icons.bluetooth,size: 50, color: Colors.white,semanticLabel: 'Bluetooth Beacon is Connected',),
                  ),
                ],
              ),
            ),

            Container(
              width:ScreenUtil().setWidth(400),
              height: ScreenUtil().setHeight(100),
              color: Colors.white,
              //child: const Text('Not Connected', style: TextStyle(color:Colors.white,fontSize:30.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width:ScreenUtil().setWidth(300),
                    height: ScreenUtil().setHeight(80),
                    decoration: const BoxDecoration(
                      color:Colors.white,
                      borderRadius:BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: const TextField(
                      style:  TextStyle(fontSize: 32.0),
                      decoration: InputDecoration(
                          hintText: "Question Asked"
                      ),
                    ),
                  ),
                  Container(
                      width:ScreenUtil().setWidth(80),
                      height: ScreenUtil().setHeight(80),
                      decoration: const BoxDecoration(
                        color:Color(0xff0b7ae6),
                        borderRadius:BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: const Icon(Icons.search, color: Colors.white,semanticLabel: 'Question is Completed',)
                  ),
                ],
              ),
            ),
            MergeSemantics(
              child: Column(children: [
                Container(
                  margin: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(0), ScreenUtil().setWidth(10), ScreenUtil().setHeight(85)),
                  width: double.infinity,
                  height: ScreenUtil().setHeight(350),
                  //decoration: const BoxDecoration(
                  //  color:Color(0xff0b7ae6),
                  //  borderRadius:BorderRadius.all(Radius.circular(120.0)),
                  //),
                  child: IconButton(
                    // We could also use the is icon maybe. It's for searching.
                    // icon: const Icon(Icons.location_searching_outlined, size: 150, color:Colors.white),
                    icon: const Icon(Icons.mic,size:350,color: Colors.white,semanticLabel: 'Getting Response',),
                    // Within the `FirstScreen` widget
                    onPressed: () {
                      // Navigate to the second screen using a named route.
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                ),
                // Add Margin to push word inwards
                Semantics(
                  excludeSemantics: true,
                  child:Padding(
                    padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), ScreenUtil().setHeight(10), ScreenUtil().setWidth(10), ScreenUtil().setHeight(40)),
                    child: Text('Getting Response', textAlign: TextAlign.center,
                        style: TextStyle(color:Colors.white,fontSize:ScreenUtil().setSp(32))),
                  ),
                )
              ],),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(0),
                  ScreenUtil().setHeight(0),
                  ScreenUtil().setWidth(10),
                  ScreenUtil().setHeight(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Semantics(
                  excludeSemantics: true,
                  child: Image(
                    image: AssetImage("images/intel_logo.png"),
                    height: ScreenUtil().setHeight(50),
                    width: ScreenUtil().setWidth(50),
                    semanticLabel: 'Intel Logo',
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}