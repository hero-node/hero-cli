
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
var LogSchema = mongoose.Schema({
    id			: ObjectId,
    name		: String,
    page		: String,
    develop		: Boolean,
    bugfix		: Boolean,
    jira		: String,
    timeStart	: Date,
  	timeEnd		: Date,
});
setTimeout(function(){
	var Log = mongoose.model('Log',LogSchema);
	var log = new Log();
	log.name = '刘国平1';
	log.save();
},1000);
