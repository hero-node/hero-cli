var request = require('request');

module.exports = function(req, res, next){
    if (req.url == '/test') {
      res.send({process:process.pid});
      res.end();
      return;
    }else if (req.path == '/ip') {
      setTimeout(function(){
        res.send({ip:req.connection.remoteAddress});
        res.end();
      },1000)
      return;
    }else if (req.path == '/upload') {
        res.send(
        {
          image:req.url
        }
      );
      res.end();
      return;
    }else if (req.path == '/idcard') {
      var options = {
       url: 'http://apis.baidu.com/chazhao/idcard/idcard?idcard='+req.query.idcard,
        headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }else if (req.path == '/joke_pic') {
      var options = {
       url: 'http://apis.baidu.com/showapi_open_bus/showapi_joke/joke_pic?page='+req.query.page,
        headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }else if (req.path == '/joke_text') {
      var options = {
       url: 'http://apis.baidu.com/showapi_open_bus/showapi_joke/joke_text?page='+req.query.page,
        headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }else if (req.path == '/tuling') {
      var options = {
       url: 'http://www.tuling123.com/openapi/api?key=30c467756f3e974d4a999df0e8777b64&info='+encodeURIComponent(req.query.info),
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }else if (req.path == '/phone_addr') {
      var options = {
       url: 'http://apis.baidu.com/showapi_open_bus/mobile/find?num='+req.query.num,
       headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }
    else if(req.path == '/translate'){
      var options = {
       url: 'http://apis.baidu.com/apistore/tranlateservice/translate?query='+encodeURIComponent(req.query.query)+'&from='+req.query.from+'&to='+req.query.to,
       headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }
    else if(req.path == '/tts'){
      var options = {
       url: 'http://apis.baidu.com/apistore/baidutts/tts?ctp=1&text='+encodeURIComponent(req.query.text)+'&per'+req.query.per,
       headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }
    else if(req.path == '/asr'){
      var options = {
       url: 'http://apis.baidu.com/apistore/vop/baiduvopjson?format=wav&rate=8000&channel=1&audioBase64='+encodeURIComponent(req.query.audioBase64)+'&lan'+req.query.lan,
       headers: {
         'apikey':'2d6ebc0f8604102fa969196929a42634'
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
    }else if(req.path == '/qcloud_sign'){
      var bucket = 'heromobile',
      projectId = '10068385',
      userid = 0,
      secretId = 'AKIDgJ5ioyQOIc0WtKKivRoEk2cqiq5Nu5DI',
      secretKey = '6IaAusv54ukcJA7DAwmhipDhYn7e0QtP';
      var tencentyun = require('tencentyun');
      tencentyun.conf.setAppInfo(projectId, secretId, secretKey);
      var fileid = '',
          expired = Math.round(+new Date()/1000) + 999,
          uploadurl = tencentyun.imagev2.generateResUrlV2(bucket, userid, fileid),
          sign = tencentyun.auth.getAppSignV2(bucket, fileid, expired);
          ret = {'sign':sign,'url':uploadurl};
      res.end(JSON.stringify(ret)); 
      return;
    }else if(req.path == '/copyStr'){
      require('child_process').exec('pbpaste',function(err, stdout, stderr) {
        res.end(stdout); 
      });
      return;
    }else if(req.path == '/replay'){
      var options = {
       url: 'http://horizon.dianrong.com/query/execute',
       method: 'POST',
       json:true,
       headers: {
        'Content-Type': 'application/json',
        'Authorization':'Basic ZGlhbnJvbmctY2xpZW50czo1MDYyMGM1Mi1lZDE0LTExZTYtOWI1My0wMDI0ZDc4NjdkMDQ=',
        },
        body:{
          "queryPlanName": "heroUserBehaviorData",
          "params": {
              "cellphone":req.query.phone 
          }
        }
      };
      request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
          res.send(body);
          res.end();
        }else{
          res.send(error);
          res.end();
        }
      });
      return;
    }
    next();
  }