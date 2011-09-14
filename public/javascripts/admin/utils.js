if (typeof window.console === 'undefined') {
  window.console = { log: function() { return false; } };
}

function makeSlug(val, sep) { // code largely inspired by http://www.thewebsitetailor.com/jquery-slug-plugin/
  if (typeof val == 'undefined') return('');
  if (typeof sep == 'undefined') sep = '_';
  var alphaNumRegexp = new RegExp('[^a-zA-Z0-9\\' + sep + ']', 'g');
  var avoidDuplicateRegexp = new RegExp('[\\' + sep + ']{2,}', 'g');
  val = val.replace(/\s/g, sep);
  val = val.replace(alphaNumRegexp, '');
  val = val.replace(avoidDuplicateRegexp, sep);
  return val.toLowerCase();
}

function addParameterToURL(key, value) { // code from http://stackoverflow.com/questions/486896/adding-a-parameter-to-the-url-with-javascript
  key = encodeURIComponent(key); value = encodeURIComponent(value);

  var kvp = document.location.search.substr(1).split('&');

  var i = kvp.length; var x; while(i--) {
    x = kvp[i].split('=');

    if (x[0] == key) {
      x[1] = value;
      kvp[i] = x.join('=');
      break;
    }
  }

  if (i < 0) { kvp[kvp.length] = [key,value].join('='); }

  //this will reload the page, it's likely better to store this until finished
  document.location.search = kvp.join('&');
}

(function() {
  String.prototype.trim = function() {
    return this.replace(/^\s+/g, '').replace(/\s+$/g, '');
  }

  String.prototype.repeat = function(num) {
    for (var i = 0, buf = ""; i < num; i++) buf += this;
    return buf;
  }
})();

Object.size = function(obj) {
  var size = 0, key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) size++;
  }
  return size;
};

// Make a DOM option for a select box. This code works around a bug in IE
function makeOption(text, value, defaultSelected, selected) {
  var option = new Option('', value, defaultSelected, selected);
  $(option).text(text);
  return option;
}
