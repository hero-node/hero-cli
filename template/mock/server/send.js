var amqp = require('amqplib/callback_api');

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'logs';
	var msg = process.argv.slice(2).join(' ') || "Hello World!";
    ch.assertExchange(ex, 'fanout', {durable: false});
	for (var i = 0; i < 1000; i++) {
    	ch.publish(ex, '', new Buffer(msg));
	};
  });
  setTimeout(function() { conn.close(); process.exit(0) }, 500);
});
