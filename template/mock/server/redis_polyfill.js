// reids用来做大规模消息转发，当服务器不支持redis pub/sub的时候或者单机（无负载均衡和集群）的情况下快速直调。

var redis_polyfill = {};
redis_polyfill.pubRedis = '';
redis_polyfill.subRedis = '';
var subs = {};
redis_polyfill.sub = function(channel,fun){
  if (redis_polyfill.subRedis) {
    redis_polyfill.subRedis.subscribe(channel);
    redis_polyfill.subRedis.on('message',function(channel,data){
      data = eval('(' + data + ')');
      fun(data);
    });
  }else{
    if (!subs[channel]) {
      subs[channel] = [];
    };
    subs[channel].push(fun);
  };
}
redis_polyfill.pub = function(channel,message){
  if (redis_polyfill.pubRedis) {
    message = JSON.stringify(message);
    redis_polyfill.pubRedis.publish(channel,message);
  }else{
    var _subs = subs[channel];
    if (_subs) {
      for(var num in _subs){
        var fun = _subs[num];
        fun(message);
      }
    };
  }
}
module.exports = redis_polyfill;