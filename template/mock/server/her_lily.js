// reids用来做大规模消息转发，当有redis作为参数传入时候，使用它，否则自己连接redis
// 一般情况下，传入的redis是假redis，只是为了fix无redis的环境。

//微服务的名字，一般使用女性名字来命名，服务一个Hero前端页面
var card = 'lily';

//微服务的业务代码
function job(message,fun){
	//任何一个消息都必须知道userid和card，所以下面四句话是所有业务逻辑里面都需要有的。
	console.log('hi '+message.sender+' I am '+card);
	var sender = message['sender'];
	var userid = message['userid']+card;
	message = {userid:userid};
	if (sender && userid ) {

		message.datas = [{name:"answer",text:" hi,I'm lily "}];
		setTimeout(function() {
			fun(sender,message);
		}, 1000);
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
