var Episode = Parse.Object.extend('Episode'),
    Track = Parse.Object.extend('Track');

var SoundCloud = {
  FetchTracksUrl: 'https://api.soundcloud.com/users/heldeepradio/tracks.json',
  ClientId: '20c0a4e42940721a64391ac4814cc8c7',
  TracksLimit: 200
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
    trackObj.title = arr[i];
    tracksArr.push(trackObj);
  }

  return tracksArr;
}


Parse.Cloud.define('fetchAll', function(request, response) {
  var data,
      episode = {},
      epObj,
      tracksArray = [],
      toSave = [];

  Parse.Cloud.httpRequest({
    url: SoundCloud.FetchTracksUrl,
    params: {
      limit: SoundCloud.TracksLimit,
      client_id: SoundCloud.ClientId
    }
  }).then(function(httpResponse) {
    // success
    data = httpResponse.data;

    data.forEach(function(episode) {
      epObj = generateEpisodeObject(episode);

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
    });

    return Parse.Object.saveAll(toSave);

  }).then(function(objs) {
    response.success('Saved all episodes & tracks.');
  }, function(err) {
    response.error(err);
  });
});
