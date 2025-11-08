import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/pages/door_closed.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  
  String name = "Sahil";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BnBAppBar(
        title: "Cart",
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowRight),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => const DoorClosedPage(),
                )
              );
            },
          )
        ],
      ),
       body: Row(
        children: [
          // ListView.builder(
          //   itemBuilder: (_, index) => 
          //     Text('Placeholder $index'),
          // ),
          Spacer(flex: 4),
          Container(
            width: MediaQuery.sizeOf(context).width/3,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50), 
                  spreadRadius: 2, 
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
              color: Theme.of(context).colorScheme.surface
            ),
            child: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                                builder: (context) => const WelcomePage(),
                            )
                          );
                        }, 
                        icon: SizedBox.square(
                          dimension: 20,
                          child: Icon(LucideIcons.circleX)
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: Size(300, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10)
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),  
                        ),
                        label: Text('Cancel Transaction'),
                      ), 
                      Container(
                        margin: EdgeInsets.all(20),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Logged in as:"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () => {}, 
                                icon: Icon(LucideIcons.squarePen, size: 14),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(10)
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(60),
                                  foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0)
                                ),
                                label: Text('Edit', style: TextStyle(fontSize: 14))
                              )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Payment Method:"),
                                Text("Dining Dollars", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                          Container(
                             margin: EdgeInsets.only(top: 20),
                             padding: EdgeInsets.all(16),
                             decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.1)),
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(40),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(width: 10),
                                Icon(LucideIcons.doorClosed),
                                SizedBox(width: 20),
                                Flexible (    
                                  child: 
                                    Text(
                                      "Finished? Close the doors to complete your transaction.",
                                      textAlign: TextAlign.left,
                                    )
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 199),
                            alignment: AlignmentDirectional.center,
                            child: SvgPicture.asset('assets/images/lockup.svg', width: 275)
                          )
                        ],
                      )
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}