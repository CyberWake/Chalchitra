class FormValidation{
  static String validateEmail(String email){
    if(email.isEmpty){
      return "Email can't be empty";
    }else{
      String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = new RegExp(p);

      if(regExp.hasMatch(email)){
        return null;
      }else{
        return "Enter a valid email";
      }
    }
  }

  static String validateLoginPassword(String password){
    if(password.isEmpty){
      return "Password can't be empty";
    }else{
      return null;
    }
  }

  static String validateRegisterPassword(String password){
    if(password.isEmpty){
      return "Password can't be empty";
    }else{
      if(password.length < 8){
        return "Password must contain atleast 8 characters";
      }else{
        Pattern pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(password)){
          return 'Password must be alpha-numeric with symbols';
        }
        else{
          return null;
        }
      }
    }
  }
}