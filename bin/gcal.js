// Generated by CoffeeScript 1.10.0
(function() {
  var CAL_NAME, CLIENT_SECRET_FILE, SCOPE, SCOPE_RO, SCOPE_RW, TITLE, TOKEN_DIR, TOKEN_PATH, authorize, checkErr, findCalId, formatTime, fs, getNewToken, google, googleAuth, insertEvents, listEvents, log, main, moment, parseEvent, readAndCreateEvents, readline, storeToken;

  log = console.log;

  fs = require('fs');

  readline = require('readline');

  google = require('googleapis');

  googleAuth = require('google-auth-library');

  moment = require('moment');

  SCOPE_RO = 'https://www.googleapis.com/auth/calendar.readonly';

  SCOPE_RW = 'https://www.googleapis.com/auth/calendar';

  SCOPE = SCOPE_RW;

  TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE) + "/.credentials/";

  TOKEN_PATH = TOKEN_DIR + "/calendar-nodejs-quickstart.json";

  CLIENT_SECRET_FILE = 'client_secret.json';

  CAL_NAME = 'Logan';

  TITLE = "Logan Macy's";

  main = function() {
    return fs.readFile(CLIENT_SECRET_FILE, function(err, content) {
      if (checkErr("reading " + CLIENT_SECRET_FILE, err)) {
        return;
      }
      return authorize(JSON.parse(content), function(auth) {
        var calendar;
        calendar = google.calendar('v3');
        return calendar.calendarList.list({
          auth: auth
        }, function(err, response) {
          var calId, i, item, len, ref;
          if (checkErr('calendarList.list', err)) {
            return;
          }
          ref = response.items;
          for (i = 0, len = ref.length; i < len; i++) {
            item = ref[i];
            if (item.summary === CAL_NAME) {
              calId = item.id;
            }
          }
          console.log('calId:', calId);
          if (!calId) {
            console.log("Did not find calendar '" + CAL_NAME + "'");
            return;
          }
          return insertEvents({
            auth: auth,
            calendarId: calId
          });
        });
      });
    });
  };

  authorize = function(credentials, callback) {
    var auth, clientId, clientSecret, oauth2Client, redirectUrl;
    clientSecret = credentials.installed.client_secret;
    clientId = credentials.installed.client_id;
    redirectUrl = credentials.installed.redirect_uris[0];
    auth = new googleAuth();
    oauth2Client = new auth.OAuth2(clientId, clientSecret, redirectUrl);
    return fs.readFile(TOKEN_PATH, function(err, token) {
      if (err) {
        return getNewToken(oauth2Client, callback);
      } else {
        oauth2Client.credentials = JSON.parse(token);
        return callback(oauth2Client);
      }
    });
  };

  getNewToken = function(oauth2Client, callback) {
    var authUrl, rl;
    authUrl = oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: [SCOPE]
    });
    console.log('Authorize this app by visiting this url: ', authUrl);
    rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    return rl.question('Enter the code from that page here: ', function(code) {
      rl.close();
      return oauth2Client.getToken(code, function(err, token) {
        if (checkErr('get access token', err)) {
          return;
        }
        oauth2Client.credentials = token;
        storeToken(token);
        return callback(oauth2Client);
      });
    });
  };

  storeToken = function(token) {
    var err, error;
    try {
      fs.mkdirSync(TOKEN_DIR);
    } catch (error) {
      err = error;
      if (err.code !== 'EEXIST') {
        throw err;
      }
    }
    fs.writeFile(TOKEN_PATH, JSON.stringify(token));
    return console.log('Token stored to ' + TOKEN_PATH);
  };

  findCalId = function(auth, summary) {
    var calId, calendar;
    calendar = google.calendar('v3');
    calId = void 0;
    calendar.calendarList.list({
      auth: auth
    }, function(err, response) {
      var i, item, len, ref, results;
      if (checkErr('calendarList.list', err)) {
        return;
      }
      ref = response.items;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        item = ref[i];
        if (item.summary === summary) {
          results.push(calId = item.id);
        } else {
          results.push(void 0);
        }
      }
      return results;
    });
    return calId;
  };

  insertEvents = function(data) {
    var calendar, rl;
    calendar = google.calendar('v3');
    console.log('Enter events like: 10/17 915a-445p');
    rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    return readAndCreateEvents(data, calendar, rl);
  };

  readAndCreateEvents = function(data, calendar, rl) {
    return rl.question('Enter event: ', function(event) {
      var end, ref, start, title;
      if (event === 'done') {
        return;
      }
      ref = parseEvent(event), start = ref[0], end = ref[1];
      title = "to " + (formatTime(end)) + " " + TITLE;
      log('%s: %s - %s  %s', start.toString().slice(4, 10), start.toString().slice(16, 21), end.toString().slice(16, 21), title);
      if (start != null) {
        return calendar.events.insert({
          auth: data.auth,
          calendarId: data.calendarId,
          resource: {
            summary: title,
            start: {
              dateTime: start
            },
            end: {
              dateTime: end
            }
          }
        }, function(err, event) {
          if (!checkErr('calendar.events.insert', err)) {
            console.log('created successfully');
          }
          return readAndCreateEvents(data, calendar, rl);
        });
      }
    });
  };

  listEvents = function(auth, calId) {
    var calendar;
    calendar = google.calendar('v3');
    return calendar.events.list({
      auth: auth,
      calendarId: calId,
      timeMin: new Date().toISOString(),
      maxResults: 10,
      singleEvents: true,
      orderBy: 'startTime'
    }, function(err, response) {
      var event, events, i, len, results, start;
      if (checkErr('calendar.events.list', err)) {
        return;
      }
      events = response.items;
      if (events.length === 0) {
        return console.log('No upcoming events found.');
      } else {
        console.log('Upcoming 10 events:');
        results = [];
        for (i = 0, len = events.length; i < len; i++) {
          event = events[i];
          start = event.start.dateTime || event.start.date;
          results.push(console.log('%s - %s', start, event.summary));
        }
        return results;
      }
    });
  };

  parseEvent = function(event) {
    var ap1, ap2, day, end, h1, h2, m1, m2, match, mon, pat, start, thisMon, thisYear, x, year;
    pat = /^ *(\d+)\/(\d+) +(\d+?):?((?:\d\d)?)([ap]?)[- ](\d+?):?((?:\d\d)?)([ap]?) *$/;
    match = event.match(pat);
    if (!match) {
      log('Input should be MM/DD hh:mm[ap]-hh:mm[ap]');
      return [];
    }
    x = match[0], mon = match[1], day = match[2], h1 = match[3], m1 = match[4], ap1 = match[5], h2 = match[6], m2 = match[7], ap2 = match[8];
    if (ap1 === '') {
      ap1 = h1 <= 7 ? 'p' : 'a';
    }
    if (ap2 === '') {
      ap2 = h2 <= 10 ? 'p' : 'a';
    }
    mon = +mon - 1;
    if (ap1 === 'p' && h1 !== '12') {
      h1 = +h1 + 12;
    }
    if (ap2 === 'p' && h2 !== '12') {
      h2 = +h2 + 12;
    }
    thisMon = new Date().getMonth();
    thisYear = new Date().getFullYear();
    year = thisYear + (thisMon > mon ? 1 : 0);
    start = new Date(year, mon, day, h1, m1, 0);
    end = new Date(year, mon, day, h2, m2, 0);
    return [start, end];
  };

  formatTime = function(date) {
    var ap, h, m;
    h = date.getHours();
    m = date.getMinutes();
    ap = h >= 12 ? 'p' : 'a';
    if (h > 12) {
      h -= 12;
    }
    if (m < 10) {
      m = '0' + m;
    }
    return h + ":" + m + ap;
  };

  checkErr = function(op, err) {
    if (err) {
      console.log("Error from " + op + ": " + err);
      return true;
    } else {
      return false;
    }
  };

  main();

}).call(this);