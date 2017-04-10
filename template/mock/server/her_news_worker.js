
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
var NewsSchema = mongoose.Schema({
    id			: ObjectId,
    title		: String,
    desc		: String,
    content		: String,
    source		: String,
    sourceUrl	: String,
    time		: Date,
    labels		: Array,
    userid		: String,
    hot			: Number,
    lat 		: Number,
    lo 			: Number,
});
var News = mongoose.model('News',NewsSchema);
//http://c.m.163.com/search/comp/MA==/20/%E6%B5%A6%E4%B8%9C.html
var jobs = [
	'网易-科技',
	'网易-社会',
	'网易-独家',
	'网易-NBA',
	'网易-历史',
	'网易-军事',
	'网易-萌',
	'网易-娱乐',
	'网易-影视音乐',
	'网易-财经',
	'网易-体育',
	'网易-足球',
	'网易-欧洲杯',
	'网易-CBA',
	'网易-跑步',
	'网易-手机',
	'网易-数码',
	'网易-移动互联',
	'网易-轻松',
	'网易-汽车',
	'网易-房产',
	'网易-游戏',
	'网易-旅游',
	'网易-健康',
	'网易-教育',
	'网易-亲子',
	'网易-时尚',
	'网易-情感',
	'网易-艺术',
	'网易-海外',
	'网易-段子',

];

var request = require('request');
function requestWithObj(option,callback,obj){var obj = obj;request(option,function(err,res,body){callback(err,res,body,obj);});}
function sleep(millis){var date = new Date();var curDate = null;do{curDate = new Date(); }while(curDate-date < millis);}
for (var i = 0; i < jobs.length; i++) {
	var job = jobs[i];
	sleep(10000);
	if (job == '网易-科技') {
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649580692/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649580692'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','科技'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

		
	};
	if (job == '网易-社会') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348648037603/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348648037603'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','社会'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-独家') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1370583240249/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1370583240249'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','独家'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-NBA') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649145984/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649145984'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','NBA'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-历史') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1368497029546/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1368497029546'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','历史'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-军事') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348648141035/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348648141035'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','军事'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-萌') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1444289532601/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1444289532601'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','萌'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-娱乐') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348648517839/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348648517839'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','娱乐'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-影视音乐') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348648650048/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348648650048'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','影视音乐'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-财经') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348648756099/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348648756099'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','财经'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-体育') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649079062/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649079062'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','体育'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-欧洲杯') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649176279/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649176279'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','欧洲杯'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-CBA') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649475931/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649475931'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','CBA'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-跑步') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1411113472760/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1411113472760'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','跑步'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-手机') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649654285/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649654285'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','手机'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});


	};
	if (job == '网易-数码') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348649776727/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348649776727'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','数码'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-移动互联') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1351233117091/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1351233117091'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','移动互联'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-轻松') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1350383429665/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1350383429665'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','轻松'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};

	if (job == '网易-汽车') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348654060988/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348654060988'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','汽车'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-房产') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348654085632/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348654085632'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','房产'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-游戏') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348654151579/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348654151579'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','游戏'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-旅游') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348654204705/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348654204705'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','旅游'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-健康') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1414389941036/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1414389941036'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','健康'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-教育') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348654225495/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348654225495'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','教育'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-亲子') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1397116135282/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1397116135282'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','亲子'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-时尚') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348650593803/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348650593803'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','时尚'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-情感') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1348650839000/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1348650839000'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','情感'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-艺术') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1441074311424/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1441074311424'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','艺术'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-海外') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1462426218632/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1462426218632'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','海外'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});

	};
	if (job == '网易-段子') {
		
		var options = {
	   		url: 'http://c.m.163.com/nc/article/headline/T1419316284722/0-40.html',
		};
		request(options, function (error, response, body) {
			if (!error && response.statusCode == 200) {
				var results = JSON.parse(body)['T1419316284722'];
				for (var i = 0; i < results.length; i++) {
					var n = results[i];
					requestWithObj({url:'http://c.m.163.com/nc/article/'+n.postid+'/full.html'}, function (error, response, body,obj) {
						if (!error && response.statusCode == 200) {
							var doc = JSON.parse(body)[obj.postid];
							News.find({title:obj.ltitle}).exec(function (err, msgs) {
							  if (err) return console.error(err);
							  if (!msgs || msgs.length < 1) {
								var news= new News();
								news.title = obj.ltitle+obj.title;
								news.desc = obj.digest;
								news.content = doc.body;
								news.source = doc.source;
								news.time = doc.ptime;
								news.hot = 100+doc.replyCount;//其实自创news才有意义
								news.labels = ['网易','段子'];
								news.save();
							  }
							});
						}
					},n);
				};
			}
		});
	};
};