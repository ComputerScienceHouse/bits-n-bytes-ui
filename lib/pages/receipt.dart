import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {

  String name = "Sahil";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: BnBAppBar(
          title: "Total"
        ),
       body: Row(
        children: [
          // ListView.builder(
          //   itemBuilder: (_, index) => 
          //     Text('Placeholder $index'),
          // ),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("Thank you!"),
                Text("Your transaction is complete."),
                
              ],
            )
          )
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
            child: Center (
                child: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Container(
                          margin: EdgeInsets.only(top:0, left: 20, right: 20, bottom: 20),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(40)),
                            color: Theme.of(context).colorScheme.secondaryFixed,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.clock,
                              color: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                    text: "Timing out in ",
                                    style: TextStyle( 
                                      color: Theme.of(context).colorScheme.secondaryContainer
                                      )
                                    ),
                                  TextSpan(
                                    text: "20", 
                                    style: TextStyle( 
                                      fontWeight: FontWeight.bold, 
                                      color: Theme.of(context).colorScheme.secondaryContainer
                                      )
                                    ),
                                  TextSpan(
                                    text: "s",
                                    style: TextStyle( 
                                      color: Theme.of(context).colorScheme.secondaryContainer
                                      )
                                  )
                                ]
                              )
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                                builder: (context) => const WelcomePage(),
                            )
                          );
                        }, 
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10)
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 16),  
                        ),
                        child: Text('Finish Transaction'),
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
                                Icon(LucideIcons.circleCheck),
                                SizedBox(width: 20),
                                Flexible (    
                                  child: 
                                    Text(
                                      "Press finish or wait for the session to time out.",
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
          )
        ],
      ),
    );
  }
}