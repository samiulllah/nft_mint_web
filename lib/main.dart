import 'package:flutter/material.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:toast/toast.dart';
import 'eth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController link = new TextEditingController();
  TextEditingController name = new TextEditingController();
  TextEditingController desc = new TextEditingController();
  NFTApi nftApi = new NFTApi();
  String accAddress;
  bool mintProgress = false;
  String status = '';

  setAccountAddress(String address) {
    setState(() {
      accAddress = address;
    });
  }

  getCurrentWalletAddress() async {
    if (ethereum == null) {
      setState(() {
        status =
            'This browser doesnot have Metamask extension please install at https://metamask.io/download.html';
      });
      return;
    }
    String address = await nftApi.getCurrentWalletConnected();
    if (address != null) {
      setState(() {
        accAddress = address;
      });
    }
  }

  @override
  void initState() {
    getCurrentWalletAddress();
    nftApi.walletChangeListener(setAccountAddress);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.black,
        title: Text(
          "NFT Minting",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (accAddress == null) {
                String address = await nftApi.connectWallet();
                setState(() {
                  accAddress = address;
                });
              }
            },
            child: Row(
              children: [
                Text(
                  accAddress == null
                      ? "Connect Wallet"
                      : accAddress.substring(0, 6) +
                          "..." +
                          accAddress.substring(38),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 30,
                )
              ],
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              mintForm()
              //RaisedButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget mintForm() {
    return Container(
      width: MediaQuery.of(context).size.width * .3,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(bottom: 20),
            child: Text(
              "Mint your NFT!",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ),
          textField("Link to asset", link),
          textField("Name your nft", name),
          textField("Describe your nft", desc),
          !mintProgress
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.topLeft,
                  child: button("Mint NFT", () {
                    mintNFT();
                  }))
              : Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.topLeft,
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 5, top: 20),
            child: Text(
              status,
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  Widget button(String text, Function onPress) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xffe06704),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: () => onPress(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(text.toUpperCase(), style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget textField(String hint, TextEditingController controller) {
    return Container(
      width: MediaQuery.of(context).size.width * .35,
      margin: EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            filled: true,
            hintStyle: TextStyle(color: Colors.grey),
            hintText: hint,
            fillColor: Color(0xfffaffff)),
      ),
    );
  }

  Future<void> mintNFT() async {
    if (ethereum == null) {
      Toast.show("No web3 provider found!", context);
      return;
    }
    if (link.text.isNotEmpty && name.text.isNotEmpty && desc.text.isNotEmpty) {
      setState(() {
        mintProgress = true;
        status = '';
      });
      Map res = await nftApi.mintNFT(link.text, name.text, desc.text);
      setState(() {
        status = res['status'];
      });
      if (res['success']) {
        setState(() {
          link.text = '';
          name.text = '';
          desc.text = '';
        });
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            status = 'Try minting more NFT!';
          });
        });
      }
      setState(() {
        mintProgress = false;
      });
    } else {
      Toast.show("All fields required!", context);
    }
  }
}
