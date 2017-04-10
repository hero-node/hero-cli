var card = 'ada';
var redis = require('redis');
var sub = redis.createClient();
var pub = redis.createClient();
sub.subscribe(card);
sub.on('message', function(channel, message) {
	console.log(message);
	message = eval('(' + message + ')');
	var sender = message['sender'];
	if (sender) {
		if(message.username == 'lgp'){
			message = {datas:[{name:"loginResult",text:"welcome "+ message.username}]};
			pub.publish(sender,JSON.stringify(message));
			message = {"command":"goto:http://10.12.200.18:3000/test/lily.html"};
			pub.publish(sender,JSON.stringify(message));
		}else{
			message = {"command":{show:{cancel:"知道了",title:"NOT YOU",content:"only lgp"}}};
			pub.publish(sender,JSON.stringify(message));
		}
	};
});
