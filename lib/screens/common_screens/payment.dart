import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class MakePayment {
  Map<String, dynamic>? paymentIntent;
  var log = Logger();

  void makePayment(recipientName, amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount);
      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: recipientName,
          googlePay: gpay,
        ),
      );
      displaySheet();
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> displaySheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      log.d("Payment sheet displayed");
    } catch (e) {
      log.e(e);
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(amount) async {
    try {
      // Replace 'YOUR_SECRET_KEY' with your actual Stripe secret key
      String secretKey =
          "sk_test_51NpN8rSJaMBnAdU7Rwr9dgYxVZ4yk3J8lQNazKj0hBv3Vn98yphDtEZ1rNY9hR6I6D4mDpcJKjoO2XbZE0Y5u5Se00Fey7EJwx";

      // Define the request body
      Map<String, dynamic> body = {
        "amount": amount, // Amount in cents (e.g., $10.00)
        "currency": "usd", // Currency code (e.g., USD)
      };

      // Make the POST request to create a PaymentIntent
      log.f(jsonEncode(body));
      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create PaymentIntent: ${response.body}");
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception("Error creating PaymentIntent: $e");
    }
  }
}
