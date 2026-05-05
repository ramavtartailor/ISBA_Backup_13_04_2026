function autoFormat(obj) {
        var date = obj;
  

     function checkValueWrapper(){
        var prevValue="";
        return function updatePrevValue(newValue){
            prevValue=newValue;
        }
    }

    function checkValue(str, max) {
      // 1. 02, we don't check, because 0->12 (month) or 0->31
      // 2. 00, we check
      if (str.charAt(0) !== "0" || str == "00") {
        //test
        console.log("&& in");

        // str to num
        var num = parseInt(str);

        // 1. not a number (below code, already filter out \D)
        // 2. # <= 0, e.g. -1
        // 3. 32 > 21 in month
        // default to 1
        if (isNaN(num) || num <= 0 || num > max) num = 1;

        // 1. month: 3 > 12's 1st char ==> 03
        // 2. month: 1 <= 12's 1st char ===> 1.toStr, later more #
        // 3. day: 2 <= 31's 1st chr ===> 2.toStr, later more #
        str =
          num > parseInt(max.toString().charAt(0)) && num.toString().length == 1
            ? "0" + num // self, no more #
            : num.toString(); // can be more num
      }
      return str;
    }

    function wrapEventListener(){
        var prevInput="";
        return function(e) {
          //test
          console.log("=== listen input ====", this.value);
    
          // date input type is text
          this.type = "text";
          // date input value to var
          var input = this.value;
    
          // del is \D, non-digit
          // e.g. 02/ -> del 2 -> actual del 2/ -> 0 (left)
          //if (/\D\/$/.test(input)) {
          //if prevInput length id greate e
          if (prevInput.length > input.length && /\d\/$/.test(prevInput)) {
            //test
            console.log("--digi slash--", input);
    
            // substr, last exclude, len-3
            input = input.substr(0, input.length - 1);
    
            //test
            console.log("--digi slash after--", input);
          }
    
          // remove non-digit
          var values = input.split("/").map(function(v) {
            // \D is not digit, so replace not digit to ""
            var replacedV = v.replace(/\D/g, "");
            return replacedV;
          });
    
          // e.g.
          // month, day
          // values == ["01", "12"]
    
          // check date, may not have
          if (values[0]) values[0] = checkValue(values[0], 12);
    
          // check month, may not have
          if (values[1]) values[1] = checkValue(values[1], 31);
    
          var output = values.map(function(v, i) {
            // test
            console.log("*** add slash", i);
    
            //var outV = v.length == 2 && i < 2 ? v + " / " : v;
            var outV = v.length == 2 && i < 2 ? v + "/" : v;
    
            return outV;
          });
    
          // join everything,
          console.log("output", output);
          console.log("substr", output.join("").substr(0, 14));
    
          // e.g. 01/01/1992 ==> 9 chars
          // 01 / 01 / 1992 ==> 13 chars
          this.value = output.join("").substr(0, 10);
          prevInput = this.value;
    
          console.log(">>> this.value", this.value);
        }
    }


    // user typing
    date.addEventListener("input",wrapEventListener());
    }