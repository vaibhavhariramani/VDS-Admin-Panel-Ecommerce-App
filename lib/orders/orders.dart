import 'package:flutter/material.dart';
import 'package:vdsadmin/orders/offlineorders2.dart';
import 'package:vdsadmin/orders/onlineorders2.dart';

class Orderspage extends StatefulWidget {
  const Orderspage({Key? key}) : super(key: key);

  @override
  _OrderspageState createState() => _OrderspageState();
}

class _OrderspageState extends State<Orderspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  MaterialButton(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: const Color(0xFFE44E4F),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black45,
                                    offset: Offset(0.0, 10.0),
                                    blurRadius: 10.0)
                              ]),
                          child: Container(
                            alignment: FractionalOffset.bottomCenter,
                            child: Image.asset(
                              'assets/images/2.png',
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.3,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Online Orders',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Orders2(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03,
                  ),
                  MaterialButton(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: const Color(0xFF6674F1),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black45,
                                    offset: Offset(0.0, 10.0),
                                    blurRadius: 10.0)
                              ]),
                          child: Container(
                            alignment: FractionalOffset.bottomCenter,
                            child: Image.asset(
                              'assets/images/3.png',
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.35,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Offline Orders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OfflineOrders2(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
