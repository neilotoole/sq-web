// utilities
var get = function (selector, scope) {
  scope = scope ? scope : document;
  return scope.querySelector(selector);
};

var getAll = function (selector, scope) {
  scope = scope ? scope : document;
  return scope.querySelectorAll(selector);
};

// setup typewriter effect in the terminal demo
if (document.getElementsByClassName('demo').length > 0) {
  var i = 0;
  var txt = `$ sq add postgres://sakila:$PASSWD@192.168.50.132/sakila
@sakila_pg  postgres  sakila@192.168.50.132/sakila

$ sq inspect @sakila_pg.actor
TABLE  ROWS  COL NAMES
actor  200   actor_id, first_name, last_name, last_update

$ sq '.actor | .[0:3] | .first_name, .last_name'
first_name  last_name
PENELOPE    GUINESS
NICK        WAHLBERG
ED          CHASE

$ sq '.actor | .[0:3] | .first_name, .last_name' --jsonl
{"first_name": "PENELOPE", "last_name": "GUINESS"}
{"first_name": "NICK", "last_name": "WAHLBERG"}
{"first_name": "ED", "last_name": "CHASE"}`;
  var typeSpeed = 50
  var outSpeed = 1
  var speed = typeSpeed;

  var switchSpeeds = {
    54: outSpeed,
    111: typeSpeed,
    138: outSpeed,
    395: typeSpeed,
    451: outSpeed,
    526: typeSpeed,
    580: outSpeed
  }

  function typeItOut () {
    if (i < txt.length) {
      let c = txt.charAt(i);
      if (c == ' ') {
        c = '&nbsp;'
      }

      if (switchSpeeds[i] > 0) {
        speed = switchSpeeds[i]
      }


      document.getElementsByClassName('demo')[0].innerHTML += c;
      i++;
      setTimeout(typeItOut, speed);
    }
  }

  setTimeout(typeItOut, 1800);
}
