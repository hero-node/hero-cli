// // reids用来做大规模消息转发，当有redis作为参数传入时候，使用它，否则自己连接redis
// // 一般情况下，传入的redis是假redis，只是为了fix无redis的环境。

// //微服务的名字，一般使用女性名字来命名，服务Hero前端页面,本例子中athena是守护神，保卫所有Her的安全
var card = 'athena';
var mongoose = require('mongoose');
mongoose.connect('mongodb://596414bf84a347dc84d52052b3b7c8a4:1480558963604f7d966875c82a299f63@mongo.duapp.com:8908/WyAoMXyzqhTgwrpjgdul');
var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function (callback) {
});
var Schema = mongoose.Schema,
    ObjectId = Schema.ObjectId;
var UserSchema = mongoose.Schema({
    id    	  : ObjectId,
    email     : String,
    name      : String,
    telphone  : String,
    wechat    : String,
    qq	      : String,
    weibo     : String,
    password  : String,
    lastLogin : Date,
});
var User = mongoose.model('User',UserSchema);
//微服务的业务代码
function job(message,fun){
	//任何一个消息都必须知道userid和sender，所以下面四句话是所有业务逻辑里面都需要有的。
	console.log('hi '+message.sender+' I am '+card);
	var sender = message['sender'];
	var userid = message['userid'];
	message = {user_card:userid+card};
	if (sender && userid ) {
		User.find({name:userid},function (err, Users) {
		  if (err) return console.error(err);
		  if (Users && Users.length > 0) {
			message.datas = [{result:"welcome "+Users[0].name}];
			message.time = Users[0].lastLogin;
			fun(sender,message);
			Users[0].lastLogin = new Date();
		  	Users[0].save();
		  }else{
		  	var newUser = new User({name:userid});
		  	newUser.save();
			message.datas = [{result:"Create User for you, your name is temprary  " + userid}];
			fun(sender,message);
		  };
		})
	};
}

//微服务通用的部分
function her(redis){
	if (redis) {
		redis.sub(card,function(message) {
			job(message,function(sender,data){
				redis.pub(sender,data);
			})
		});
	}else{
		var redis = require('redis');
		var pub = redis.createClient();
		var sub = redis.createClient();
		sub.subscribe(card);
		sub.on('message',function(channel,message){
			message = eval('(' + message + ')');
			job(message,function(sender,data){
				data = JSON.stringify(data);
				pub.publish(sender,data);
			});
		});
	};
}
if (exports) {
	module.exports = her;
}else{
	her();
};
