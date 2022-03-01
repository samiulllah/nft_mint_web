import 'dart:js';
import 'dart:js_util';
import 'package:flutter/cupertino.dart';
import 'package:flutter_web3_provider/ethereum.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:toast/toast.dart';

class NFTApi {
  String address =
      '0x64091cF01f32C104DbBB80b57C537738d171A253'; // of account to sign transaction
  String ethereumClientUrl =
      'https://goerli.infura.io/v3/df064891c10a4d83bab826e180ded69e'; //provider url
  String contractName = "NFT";
  String private_key =
      "2bf5961a4a4217b100f56aa761cf3094e06eed5ee8c308b91fde23418c65a048"; // of signing account

  mintNFT(String link, String name, String desc) async {
    Web3Provider web3;
    // String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x835DaAfD9F1F4b974408c4255B59A9e753728cA0";
    // upload to pinata
    String tokenURI =
        await uploadToPinata({'link': link, 'name': name, 'desc': desc});
    if (tokenURI == null) {
      return {
        'success': false,
        'status': "😢 Something went wrong while uploading your tokenURI.",
      };
    }
    // get contract
    web3 = Web3Provider(ethereum);
    var contract = Contract(
        contractAddress,
        [
          "function mintNFT(address recipient, string memory tokenURI)public returns(uint256)",
          "function balanceOf(address owner) public view  returns (uint256)"
        ],
        web3);
    //send signed transaction to contract
    var contract2 = contract.connect(web3.getSigner());
    try {
      var res = await promiseToFuture(allowInterop(callMethod(
          contract2, "mintNFT", [ethereum.selectedAddress, tokenURI])));
      print("Transferred: ${res.toString()}");
      return {
        'success': true,
        'status': "Your NFT is minted successfully!",
      };
    } catch (e) {
      return {
        'success': false,
        'status': "Failed to mint your nft!",
      };
    }
    // var res = await promiseToFuture(
    //     callMethod(contract, "balanceOf", [ethereum.selectedAddress]));
    // print("balance of ${ethereum.selectedAddress} = ${res.toString()}");
  }

  connectWallet() async {
    if (ethereum != null) {
      await promiseToFuture(
          ethereum.request(RequestParams(method: 'eth_requestAccounts')));
      return ethereum.selectedAddress.toString();
    } else {
      return null;
    }
  }

  getCurrentWalletConnected() async {
    if (ethereum != null) {
      var accounts = await promiseToFuture(
          ethereum.request(RequestParams(method: 'eth_accounts')));
      return accounts[0];
    } else {
      return null;
    }
  }

  walletChangeListener(Function setNewAccouunt) async {
    if (ethereum != null) {
      ethereum.on("accountsChanged", allowInterop((acc) {
        setNewAccouunt(acc[0].toString());
      }));
    }
  }

  uploadToPinata(Map jsonBody) async {
    try {
      const url = 'https://api.pinata.cloud/pinning/pinJSONToIPFS';
      var dio = new Dio();
      dio.options.headers['pinata_api_key'] = 'a954f202c54a60f04325';
      dio.options.headers["pinata_secret_api_key"] =
          "6a69b05ead4d846abb507ffc38b0f2a3ea2f2e50df1899065f818f67d0ff789a";
      var response = await dio.post(url, data: jsonBody);
      String pinataURl = "https://gateway.pinata.cloud/ipfs/" +
          response.data['IpfsHash'].toString();
      print(pinataURl);
      return pinataURl;
    } catch (e) {
      print("Error pinning to pinata $e");
      return null;
    }
  }
}
