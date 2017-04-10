var card = 'chat';
var redis = require('redis');
var pub = redis.createClient('6379', '10.9.15.179');
var sub = redis.createClient('6379', '10.9.15.179');
sub.subscribe(card);

var mongoose = require('mongoose');
mongoose.connect('mongodb://10.9.15.179/test');
var db = mongoose.connection;
db.on('error', function(err){
	console.log(err);
});
db.once('open', function (callback) {
	console.log(callback);
});
var Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;
var MsgSchema = mongoose.Schema({
    id			: ObjectId,
    text		: String,
    image		: String,
    userid		: String,
    group		: String,
    time		: Date,
});
var ChatMsg = mongoose.model('ChatMsg',MsgSchema);

//vars
var users = [];
var groups = {};
sub.on('message',function(channel,msg){
	msg = JSON.parse(msg);
	if (msg.hero) {
		var userid = msg.hero.userid;
		var sender = msg.hero.sender;
		var pubStr = msg.hero.pub;
		var subs = msg.hero.subs;
		msg.hero = undefined;
		msg.userid = userid;
		for (var i = 0; i < subs.length; i++) {
			var subStr = subs[i];
			if (!groups[subStr]) {
				groups[subStr] = [];
			};
			if (!contain(groups[subStr],sender)) {
				groups[subStr].push(sender);
			};
		};
		msg.group = pubStr;
		var newMsg = new ChatMsg(msg);
		newMsg.time = Date();
		newMsg.save(function(err,msg){
			console.log('err:'+err);
			console.log('ms=g:'+msg);
		});
		for (var i = 0; i < groups[pubStr].length; i++) {
			var sender = groups[pubStr][i];
	      	pub.publish(sender,JSON.stringify(msg));
		};	
	}else if (msg.command == 'join') {
		var userid = msg.user.userid;
		var sender = msg.user.sender;
		var subs = msg.user.subs;
		for (var i = 0; i < subs.length; i++) {
			var subStr = subs[i];
			if (!users[subStr]) {
				users[subStr] = [];
			};
			if (!contain(users[subStr],userid)) {
				users[subStr].push(userid);
			};
			ChatMsg.find({group:subStr}).sort({'time':-1}).limit(20).exec(function (err, msgs) {
			  if (err) return console.error(err);
			  if (msgs && msgs.length > 0) {
	      		pub.publish(sender,JSON.stringify({group:userid,msgs:msgs.reverse()}));
			  }
			});
		};
	}else if (msg.command == 'leave') {
		var userid = msg.user.userid;
		var subs = msg.user.subs;
		for (var i = 0; i < subs.length; i++) {
			var subStr = subs[i];
			remove(users[subStr],userid);
		};
	};

});
function contain(arr,value){for(var i=0;i<arr.length;i++){if(arr[i]==value) return true;}return false;};
function remove(arr,value) {if(!arr)return;var a = arr.indexOf(value);if (a >= 0){arr.splice(a, 1)}}; 


