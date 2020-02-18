import 'package:flutter/material.dart';

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText, caller, buttonLabel;
  final Image image;
  final Function(VoidCallback) handleAction;
  final bool clicked;
  final VoidCallback onClick;
  final IconData customIcon;

  CustomDialog(
      {this.title,
      this.description,
      this.buttonText,
      this.image,
      this.handleAction,
      this.caller,
      this.onClick,
      this.clicked,
      this.buttonLabel,
      this.customIcon});

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              !clicked || caller != 'calibrator'
                  ? buttonLabel == null
                      ? SizedBox.shrink()
                      : FlatButton(
                          child: Text(
                            buttonLabel,
                            style: TextStyle(color: Colors.green),
                          ),
                          onPressed: () {
                            onClick();
                            handleAction(() => {Navigator.of(context).pop()});
                          },
                        )
                  : Text('Hold still...'),
              SizedBox(height: 24.0),
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: Consts.avatarRadius,
            child: Icon(this.customIcon, size: 90.0, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
