import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
import 'package:flutter_app/resources/widgets/safearea_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:wp_json_api/models/responses/wc_customer_info_response.dart';
import 'package:wp_json_api/models/responses/wc_customer_updated_response.dart';
import 'package:wp_json_api/wp_json_api.dart';

class AccountBillingDetailsPage extends StatefulWidget {
  AccountBillingDetailsPage();

  @override
  _AccountBillingDetailsPageState createState() =>
      _AccountBillingDetailsPageState();
}

class _AccountBillingDetailsPageState extends State<AccountBillingDetailsPage> {
  _AccountBillingDetailsPageState();

  // BILLING TEXT CONTROLLERS
  final TextEditingController _txtShippingFirstName = TextEditingController(),
      _txtShippingLastName = TextEditingController(),
      _txtShippingAddressLine = TextEditingController(),
      _txtShippingCity = TextEditingController(),
      _txtShippingState = TextEditingController(),
      _txtShippingPostalCode = TextEditingController(),
      _txtShippingCountry = TextEditingController();

  bool _isLoading = true, _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    WCCustomerInfoResponse wcCustomerInfoResponse =
        await WPJsonAPI.instance.api((request) async {
      return request.wcCustomerInfo((await readAuthToken())!);
    });

    Billing billing = wcCustomerInfoResponse.data!.billing!;
    _txtShippingFirstName.text = billing.firstName!;
    _txtShippingLastName.text = billing.lastName!;

    _txtShippingAddressLine.text = billing.address1!;
    _txtShippingCity.text = billing.city!;
    _txtShippingState.text = billing.state!;
    _txtShippingPostalCode.text = billing.postcode!;
    _txtShippingCountry.text = billing.country!;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(trans("Billing Details")),
        centerTitle: true,
      ),
      body: SafeAreaWidget(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: _isLoading
              ? AppLoaderWidget()
              : LayoutBuilder(
                  builder: (context, constraints) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans("First Name"),
                                      controller: _txtShippingFirstName,
                                      shouldAutoFocus: true,
                                    ),
                                  ),
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans("Last Name"),
                                      controller: _txtShippingLastName,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              ),
                              TextEditingRow(
                                heading: trans("Address Line"),
                                controller: _txtShippingAddressLine,
                              ),
                              Row(children: <Widget>[
                                Flexible(
                                  child: TextEditingRow(
                                    heading: trans("City"),
                                    controller: _txtShippingCity,
                                  ),
                                ),
                                Flexible(
                                  child: TextEditingRow(
                                      heading: trans("State"),
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _txtShippingState),
                                ),
                              ]),
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans("Postal code"),
                                      controller: _txtShippingPostalCode,
                                    ),
                                  ),
                                  Flexible(
                                    child: TextEditingRow(
                                      heading: trans("Country"),
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _txtShippingCountry,
                                    ),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColor.get(context)!.surfaceBackground,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: (Theme.of(context).brightness ==
                                    Brightness.light)
                                ? wsBoxShadow()
                                : null,
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        height:
                            (constraints.maxHeight - constraints.minHeight) *
                                0.6,
                      ),
                      Column(
                        children: <Widget>[
                          PrimaryButton(
                            title: trans("UPDATE DETAILS"),
                            isLoading: _isUpdating,
                            action: _updateBillingDetails,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  _updateBillingDetails() async {
    String firstName = _txtShippingFirstName.text;
    String lastName = _txtShippingLastName.text;
    String addressLine = _txtShippingAddressLine.text;
    String city = _txtShippingCity.text;
    String state = _txtShippingState.text;
    String postalCode = _txtShippingPostalCode.text;
    String country = _txtShippingCountry.text;

    String? userToken = await readAuthToken();

    setState(() {
      _isUpdating = true;
    });

    WCCustomerUpdatedResponse? wcCustomerUpdatedResponse;
    try {
      wcCustomerUpdatedResponse = await WPJsonAPI.instance.api((request) =>
          request.wcUpdateCustomerInfo(userToken,
              billingFirstName: firstName,
              billingLastName: lastName,
              billingAddress1: addressLine,
              billingCity: city,
              billingState: state,
              billingPostcode: postalCode,
              billingCountry: country));
    } on Exception catch (_) {
      showToastNotification(context,
          title: trans("Oops!"),
          description: trans("Something went wrong"),
          style: ToastNotificationStyleType.DANGER);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }

    if (wcCustomerUpdatedResponse != null &&
        wcCustomerUpdatedResponse.status == 200) {
      showToastNotification(context,
          title: trans("Success"),
          description: trans("Account updated"),
          style: ToastNotificationStyleType.SUCCESS);
      Navigator.pop(context);
    }
  }
}
