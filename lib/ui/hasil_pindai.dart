import 'package:flutter/material.dart';
import 'package:poverty_lens/temp/background.dart';

class HasilPindaiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(25, 254, 1, 84),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PovertyLens AI Menjawab',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('images/map.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Vestibulum ut tortor ut purus volutpat cursus. Phasellus sed dictum orci. Mauris non interdum nunc. Suspendisse varius purus justo, at ullamcorper nulla tempor nec. Praesent aliquam eu justo nec fermentum.',
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sed volutpat faucibus diam, id interdum tortor tristique ac. Nulla facilisi. Ut tincidunt ligula in purus suscipit, vel volutpat ipsum varius. Proin vel lectus euismod, convallis leo ut, ullamcorper purus.',
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
