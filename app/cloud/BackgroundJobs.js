var Episode = Parse.Object.extend('Episode'),
    Track = Parse.Object.extend('Track');

var SoundCloud = {
  FetchTracksUrl: 'https://api.soundcloud.com/users/heldeepradio/tracks.json',
  ClientId: '20c0a4e42940721a64391ac4814cc8c7',
  TracksLimit: 3
};

var SpecialTrackTypesRegex = /Heldeep Radio Cooldown|Heldeep Cooldown|Heldeep Radio Classic|Heldeep Classic|Heldeep Radio Halfbeat|Heldeep Halfbeat/;

var TRACKLIST_DATA = require('cloud/tracklistData');

/**
 * Format episode object from SC data
 * @param  {Object} ep : episode object
 * @return {Object}    formatted episode
 */
function generateEpisodeObject(ep) {
  var epId = getEpisodeId(ep.title);
  return {
    epId: epId,
    scId: ep.id,
    scCreatedAt: ep.created_at,
    title: ep.title,
    description: ep.description,
    duration: ep.duration,
    purchaseUrl: ep.purchase_url,
    streamUrl: ep.stream_url,
    permalinkUrl: ep.permalink_url
  };
}

/**
 * Gets episode ID (number) from episode title
 * @param  {String} title : episode title
 * @return {Number}       episode ID
 */
function getEpisodeId(title) {
  var matches = title.match(/#[0-9]{3}/);
  if (!matches) {
    console.error('Couldn\'t find an episode ID match for: ', title);
    return;
  }
  return parseInt(matches[0].substring(1), 10);
}

/**
 * Gets array of track objects from episode description
 * @param  {String} description : episode description
 * @param  {Number} parentEpId  : episode ID
 * @return {Array}              array of track objects
 */
function getTracks(description, parentEpId) {
  var arr = description.split(/[^0-9][0-9]{1,2}[.)] /),
      tlen,
      i,
      tracksArr = [],
      trackObj,
      specialMatch,
      isSpecial = false;

  arr.shift(); // Remove first element, which is never a track
  tlen = arr.length;

  for (i = 0; i < tlen; i++) {
    trackObj = {
      type: isSpecial ? specialMatch : null,
      episode: parentEpId,
      order: i + 1
    };
    specialMatch = arr[i].match(SpecialTrackTypesRegex);
    if (specialMatch) {
      specialMatch = specialMatch[0];
      arr[i] = arr[i].replace(specialMatch, '');
      isSpecial = true;
    } else {
      isSpecial = false;
    }
    trackObj.title = arr[i].trim();
    tracksArr.push(trackObj);
  }

  return tracksArr;
}

function parseTime(timeStr) {
  if (!timeStr) {
    return null;
  }
  if (timeStr.indexOf('min') !== -1) {
    return parseInt(timeStr.replace('min', ''), 10) * 60;
  } else {
    var timeArr = timeStr.split(':');
    timeArr.slice(Math.max(0, timeArr.length - 3));
    timeArr = timeArr.map(function(n) { return parseInt(n, 10) || 0; });
    switch (timeArr.length) {
      case 1:
        return timeArr[0];
      case 2:
        return timeArr[0] * 60 + timeArr[1];
      case 3:
        return timeArr[0] * 3600 + timeArr[1] * 60 + timeArr[2];
      default:
        return null;
    }
  }
}

// Parse job to fetch the latest episode. This runs periodically
Parse.Cloud.job('fetchLatest', function(request, status) {
  var today = new Date(),
      weekday = today.getDay();
  // If today is Friday or Saturday
  if (weekday === 5 || weekday === 6) {

    var data,
      episode,
      epObj,
      strEpId,
      results,
      order,
      timestamp,
      timestampObj = {},
      tracksArray = [],
      toSave = [],
      latestEpId;

    Parse.Cloud.httpRequest({
      url: SoundCloud.FetchTracksUrl,
      params: {
        limit: SoundCloud.TracksLimit,
        client_id: SoundCloud.ClientId
      }
    }).then(function(httpResponse) {
      // success
      data = httpResponse.data;

      episode = data[0];

      epObj = generateEpisodeObject(episode);

      var query = new Parse.Query(Episode);
      query.descending('epId');
      return query.first();
    }).then(function(storedEp) {
      latestEpId = storedEp.get('epId');
      // There is a new episode
      if (epObj.epId > latestEpId) {
        var episodeParseObj = new Episode();

        episodeParseObj.set('epId',         epObj.epId);
        episodeParseObj.set('scId',         epObj.scId);
        episodeParseObj.set('scCreatedAt',  epObj.scCreatedAt);
        episodeParseObj.set('title',        epObj.title);
        episodeParseObj.set('description',  epObj.description);
        episodeParseObj.set('duration',     epObj.duration);
        episodeParseObj.set('purchaseUrl',  epObj.purchaseUrl);
        episodeParseObj.set('streamUrl',    epObj.streamUrl);
        episodeParseObj.set('permalinkUrl', epObj.permalinkUrl);

        tracksArray = getTracks(episode.description, epObj.epId);
        tracksArray.forEach(function(trackObj) {

          var trackParseObj = new Track();

          trackParseObj.set('title',   trackObj.title);
          trackParseObj.set('type',    trackObj.type);
          trackParseObj.set('order',   trackObj.order);
          trackParseObj.set('episode', episodeParseObj);

          toSave.push(trackParseObj);
        });

        return Parse.Object.saveAll(toSave);
      } else {
        return false;
      }
    }).then(function(objs) {
      if (objs) {
        var notificationQuery = new Parse.Query(Parse.Installation);
        return Parse.Push.send({
          where: notificationQuery,
          data: {
            alert: 'It\'s that time of the week again – Heldeep #' + epObj.epId + ' is out!'
          }
        });
      } else {
        status.success('No new episodes to save.');
      }
    }, function(err) {
      status.error(err);
    }).then(function(sent) {
      if (sent) {
        // status.success('Successfully saved episodes & tracks and sent notifications.');
        strEpId = Array(4 - epObj.epId.toString().length).join('0') + epObj.epId;

        var q = encodeURIComponent('1001 tracklists heldeep ' + strEpId),
            url = 'http://www.google.com/search?q=' + q,
            importUrl = 'https://api.import.io/store/connector/_magic?url=' + encodeURIComponent(url) + '&format=JSON&js=false&infiniteScrollPages=0&_apikey=defddb31353f4930993f61643f76321696f3f7ce7836958aedae0a638bed8a2c55c38aeacf17c63fd3016104560c212a1ed5983422d40d5e5737ea37c407d6c3af2ca0a8c366af8584ab15368408e33a';

        return Parse.Cloud.httpRequest({
          url: importUrl
        });
      }
    }, function(err) {
      status.error('Could not send notifications: ' + err);
    }).then(function(httpResponse) {
      if (httpResponse) {
        var data = httpResponse.data,
            result = data.tables[0].results[0],
            title = result['r_link/_text'],
            lowercaseTitle = title.toLowerCase(),
            link = result['r_link'],
            promise = new Parse.Promise();

        if ((lowercaseTitle.indexOf('heldeep') != -1) && (lowercaseTitle.indexOf(strEpId) != -1)) {
          promise.resolve(link);
          return promise;
        }
      }
    }).then(function(tracklistUrl) {
      if (tracklistUrl) {
        return Parse.Cloud.httpRequest({
          url: 'https://api.import.io/store/connector/_magic?url=' + encodeURIComponent(tracklistUrl) + '&format=JSON&js=false&infiniteScrollPages=0&_apikey=defddb31353f4930993f61643f76321696f3f7ce7836958aedae0a638bed8a2c55c38aeacf17c63fd3016104560c212a1ed5983422d40d5e5737ea37c407d6c3af2ca0a8c366af8584ab15368408e33a'
        });
      } else {
        status.success('Couldn\'t find tracklist URL.');
      }
    }).then(function(httpResponse) {
      var promise = new Parse.Promise();
      // Success
      data = httpResponse.data;
      results = data.tables[0].results;
      if (results) {
        results.forEach(function(res) {
          order = parseInt(res['tlfontlarge_number/_source'], 10) || undefined;
          timestamp = order ? parseTime(res['cuevaluefield_value']) : null;
          timestampObj[String(order)] = timestamp;
        });

        promise.resolve(timestampObj);

        return promise;
      } else {
        status.success('Couldn\'t find tracklist timestamps.');
      }
    }).then(function(obj) {
      // obj is the object of timestamps
      // Find episode first
      var query = new Parse.Query(Episode);
      query.equalTo('epId', epObj.epId);
      return query.first();
    }).then(function(episode) {
      var query = new Parse.Query(Track);
      query.equalTo('episode', episode);
      return query.find();
    }).then(function(tracks) {
      var toSave = [],
          order,
          timestamp;

      tracks.forEach(function(track) {
        order = track.get('order');
        timestamp = timestampObj[String(order)] || null;
        track.set('timestamp', timestamp);

        if (timestamp) {
          toSave.push(track);
        }
      });

      return Parse.Object.saveAll(toSave);
    }).then(function(obj) {
      if (obj) {
        status.success('It\'s a miracle! Everything worked.');
      } else {
        status.error('Couldn\'t save timestamps.');
      }
    });
  } else {
    status.error('Invalid weekday.');
  }
});


// Parse.Cloud.define('fetchTracklistUrl', function(request, response) {
//   var message = '',
//       epId = 84,
//       strEpId = Array(4 - epId.toString().length).join('0') + epId,
//       q = encodeURIComponent('1001 tracklists heldeep ' + strEpId),
//       url = 'http://www.google.com/search?q=' + q,
//       importUrl = 'https://api.import.io/store/connector/_magic?url=' + encodeURIComponent(url) + '&format=JSON&js=false&infiniteScrollPages=0&_apikey=defddb31353f4930993f61643f76321696f3f7ce7836958aedae0a638bed8a2c55c38aeacf17c63fd3016104560c212a1ed5983422d40d5e5737ea37c407d6c3af2ca0a8c366af8584ab15368408e33a';

//   Parse.Cloud.httpRequest({
//     url: importUrl
//   }).then(function(httpResponse) {
//     var data = httpResponse.data,
//         result = data.tables[0].results[0],
//         title = result['r_link/_text'],
//         lowercaseTitle = title.toLowerCase(),
//         link = result['r_link'],
//         promise = new Parse.Promise();


//     if ((lowercaseTitle.indexOf('heldeep') != -1) && (lowercaseTitle.indexOf(strEpId) != -1)) {
//       promise.resolve(link);
//       return promise;
//     }
//   }).then(function(link) {
//     if (link) {
//       response.success('Success! Link: ' + link);
//     } else {
//       response.error('No link found. ' + message);
//     }
//   });
// });


// Job to fetch timestamps for all episodes, given data array of 1001tracklists URLs
Parse.Cloud.job('setAllTimestamps', function(request, status) {
  var promises = [];

  TRACKLIST_DATA.forEach(function(elem) {
    promises.push(Parse.Cloud.run('setTimestamps', {
      'epId' : elem.epId,
      'tracklistUrl' : elem.tracklistUrl
    }));
  });

  return Parse.Promise.when(promises)
    .then(function() {

    status.success('success!');

  }, function(err) {
    status.error('error: ' + err);
  });
});
