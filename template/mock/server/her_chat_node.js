var group = 'test1';
var userid = 'machine@'+group;
var users = [];
var fms = require('Stately.js');
var loan = fms.machine({
    'STEP1': {
        in: function (msg) {
            return this.PLAYING;
        }
    },
    'PLAYING': {
        stop: function () {
            return this.STOPPED;
        },
        pause: function () {
            return this.PAUSED;
        }
    },
    'PAUSED': {
        play: function () {
            return this.PLAYING;
        },
        stop: function () {
            return this.STOPPED;
        }
    }
}).bind(function (event, oldState, newState) {

    var transition = oldState + ' => ' + newState;

    switch (transition) {
        /*
        ...
        case 'STOPPED => PLAYING':
        case 'PLAYING => PAUSED':
        ...
        */
        default:
            console.log(transition);
            break;
    }
});







var io = require('/Users/liuguoping/hero-mobile/hero-js/server/node_modules/socket.io/node_modules/socket.io-client/index.js')

io = io.connect('http://localhost:3000');
io.on('connect',function(){
    io.emit('sub', {card:'chat',pub:'test1',subs:['test1'],userid:userid});
});
io.on('disconnect',function(){
	console.log('disconected');
});
io.on('message',function(data){
	if (data.msgs) {
	}else{
		if (userid !== data.userid) {
			processMsg(data.text);
		};
	}
});
function processMsg(msg){


	io.emit('message',{text:'呵呵'+msg});
}
function contain(arr,value){for(var i=0;i<arr.length;i++){if(arr[i]==value) return true;}return false;};
function remove(arr,value) {if(!arr)return;var a = arr.indexOf(value);if (a >= 0){arr.splice(a, 1)}}; 


