var Episode = Parse.Object.extend('Episode'),
    Track = Parse.Object.extend('Track');

var SoundCloud = {
  FetchTracksUrl: 'https://api.soundcloud.com/users/heldeepradio/tracks.json',
  ClientId: '20c0a4e42940721a64391ac4814cc8c7',
  TracksLimit: 3
};
var SpecialTrackTypesRegex = /Heldeep Radio Cooldown|Heldeep Cooldown|Heldeep Radio Classic|Heldeep Classic|Heldeep Radio Halfbeat|Heldeep Halfbeat/;


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

function getEpisodeId(title) {
  var matches = title.match(/#[0-9]{3}/);
  if (!matches) {
    console.error('Couldn\'t find an episode ID match for: ', title);
    return;
  }
  return parseInt(matches[0].substring(1), 10);
}

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
      episode: parentEpId
    };
    specialMatch = arr[i].match(SpecialTrackTypesRegex);
    if (specialMatch) {
      specialMatch = specialMatch[0];
      arr[i] = arr[i].replace(specialMatch, '');
      isSpecial = true;
    } else {
      isSpecial = false;
    }
    trackObj.title = arr[i];
    tracksArr.push(trackObj);
  }

  return tracksArr;
}

var message = "";

Parse.Cloud.job('fetchLatest', function(request, status) {
  var today = new Date(),
      weekDay = today.getDay();
  // If today is Friday or Saturday
  if (weekday === 5 || weekday === 6) {

    var data,
      episode,
      epObj,
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
          trackParseObj.set('episode', episodeParseObj);

          toSave.push(trackParseObj);
        });

        return Parse.Object.saveAll(toSave);
      } else {
        return false;
      }
    }).then(function(objs) {
      status.success(objs ? 'Saved new episode & tracks.' : 'No new episodes to save.');
    }, function(err) {
      status.error(err);
    });
  }
});
