var card = 'heros';
var redis = require('redis');
var pub = redis.createClient('6379', '10.9.14.137');
var sub = redis.createClient('6379', '10.9.14.137');
sub.subscribe(card);

var mongoose = require('mongoose');
mongoose.connect('mongodb://10.9.14.137/test');
var db = mongoose.connection;
db.on('error', function(err){
	console.log(err);
});
db.once('open', function (callback) {
	console.log(callback);
});
var Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;
var UserSchema = mongoose.Schema({
    id			: ObjectId,
    userid		: String,
    passwordMD5	: String,
    nickname	: String,
    avatar		: String,
    sex			: String,
    signature	: String,
    realname	: String,
    telephone	: String,
    email		: String,
    area		: String,
    qq			: String,
    wechat		: String,
});
var User = mongoose.model('User',UserSchema);

sub.on('message',function(channel,msg){
	console.log('User in:'+msg);
	msg = JSON.parse(msg);
	if (msg.hero) {
		var userid = msg.hero.userid;
		var sender = msg.hero.sender;
		var pubStr = msg.hero.pub;
		var subStr = msg.hero.subs[0];
		if (userid != pubStr) {
			User.findOne({userid:subStr},function (err, user) {
			  if (err) return console.error(err);
			  user._doc.group = userid;
			  console.log('User out:'+JSON.stringify(user));
			  pub.publish(sender,JSON.stringify(user));
			});
		}else{
			var msgUser = msg.user;
			User.findOne({userid:subStr},function (err, user) {
			  if (err) return console.error(err);
			  if (!user) {
			  	user = new User({userid:subStr});
			  }
			  merge(user,msgUser);
			  user.save();
			  user._doc.group = userid;
			  console.log('User out:'+JSON.stringify(user));
			  pub.publish(sender,JSON.stringify(user));
			});
		}
	}else if (msg.command == 'join') {
	}else if (msg.command == 'leave') {
	};

});
function merge(o1,o2){for(var key in o2){o1[key]=o2[key]}return o1};
function contain(arr,value){for(var i=0;i<arr.length;i++){if(arr[i]==value) return true;}return false;};
function remove(arr,value) {if(!arr)return;var a = arr.indexOf(value);if (a >= 0){arr.splice(a, 1)}}; 


