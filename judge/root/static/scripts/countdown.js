if (typeof(contest_start) !== 'undefined' && contest_start !== null) {
  $(function(){
    var tex = $('#time_elapsed');

    var ok = false;
    var ival = null;

    ival = window.setInterval(function() {
      var now = new Date();
      var diff = now.getTime() - contest_start.getTime();
      var since = new Date(diff);

      if (diff < contest_duration * 1000 + 1000) {
        ok = true;
      }
      else {
        window.clearInterval(ival);

        if (ok) {
          location.reload();
        }
        return;
      }

      var fmt = function(s) {
        s = new String(s);
        while (s.length < 2) s = '0' + s;
        return s;
      }

      tex.text(fmt(since.getUTCHours()) +
         ':' + fmt(since.getUTCMinutes()) +
         ':' + fmt(since.getUTCSeconds()));

    }, 1000);
  });
}
