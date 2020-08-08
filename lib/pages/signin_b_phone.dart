import 'package:antri_tino/utils/focus_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:antri_tino/pages/signin_c_otp.dart';

class AuthPhonePage extends StatefulWidget {
  AuthPhonePage({Key key}) : super(key: key);

  String inputPrefix = "+62";

  @override
  AuthPhonePageState createState() => AuthPhonePageState();
}

class AuthPhonePageState extends State<AuthPhonePage> {
  final TextEditingController inputController = TextEditingController();

  final FocusNode focusPrefixInput = FocusNode();
  final FocusNode focusPhoneInput = FocusNode();

  bool isValid;

  @override
  void initState() {
    isValid = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                showBanner(),
                showLeadingMessage(),
                showInput(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: showContinueButton(),
    );
  }

  Widget showBanner() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
    );
  }

  Widget showLeadingMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(text: 'Halo!\n', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            TextSpan(text: 'Enter your mobile number to continue.', style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal)),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget showInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: Row(
          children: <Widget>[
            DropdownButton<String>(
              focusNode: focusPrefixInput,
              value: widget.inputPrefix,
              icon: Icon(Icons.arrow_drop_down),
              elevation: 1,
              isExpanded: false,
              isDense: false,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 20.0,
                fontFamily: 'Ubuntu',
              ),
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
              onChanged: (String newValue) {
                setState(() {
                  widget.inputPrefix = newValue;
                  FocusUtil.fieldFocusChange(context, focusPhoneInput);
                });
              },
              items: <String>['+62', '+65']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: TextFormField(
                focusNode: focusPhoneInput,
                keyboardType: TextInputType.number,
                controller: inputController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
                  ),
                ),
                autofocus: true,
                autovalidate: true,
                autocorrect: false,
                maxLengthEnforced: true,
                maxLength: 15,
                maxLines: 1,
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                onChanged: (text) {
                  validate();
                },
              ),
            ),
          ],
        )
    );
  }

  Widget showContinueButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: SizedBox(
          height: 30.0,
          child: FlatButton(
            color: Colors.transparent,
            textColor: (isValid ? Theme.of(context).accentColor : Colors.grey),
            child: Text('Continue', style: TextStyle(
              fontSize: 20.0,
            )),
            onPressed: () { validateAndContinue(); },
          ),
        ));
  }

  Future<void> validate() async {
    if (inputController.text.length >= 8 && inputController.text.length <= 12) {
      setState(() {
        isValid = true;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  void validateAndContinue() {
    if (isValid) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AuthOTPPage(
                  mobileNumber: "${widget.inputPrefix}${inputController.text}",
                ),
          ));
    }
  }
}

