/*
Copyright 2017 Material Cause LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


let express = require('express');
let connection = require('./connection');
let bodyParser = require ('body-parser');
let app = express();
let socketserver = require('http').createServer();
let io = require('socket.io')(socketserver);
let socketClientsArray = [];
let activeTokensArray = [];
connection.init();

app.use(bodyParser.urlencoded({ extended: true}));
app.use(bodyParser.json());
app.use(bodyParser.json({type: 'application/vnd.api+json'}));

app.get('/userinfo',
function(request,response)
{
  console.log("userinfo/get entered");
  let token = request.query.token;
  //console.log(request.query.token);
  isInArray = false;
  let userArrayData;
  activeTokensArray.forEach(function(tokenArray)
  {
    tokenArray[1].replace("'", "");
    if(tokenArray[1] == token)
    {
      isInArray = true;
      userDataArray = tokenArray;
    }
  });//end activeTokensArray.forEach&function
  if (isInArray)
  {
    connection.acquire(
    function(err, con)
    {
      con.query('SELECT id, first_name, last_name, username, plan_id, street_address, city_state_zip, active, number from users WHERE id = ? LIMIT 1',
      [userDataArray[0]],
      function(err,rows,fields)
      {
        console.log("Sending userinfo");
        response.send({user:rows});
        con.release();
      });
    });
  }
  else
  {
    console.log("Invalid token, empty user info sent");
    console.log(request.query.token);
    console.log(activeTokensArray);
    console.log("Plans query token and active tokens array")
    response.send({"user":null})//respond with null
  }
});//end app.get&function

app.post ('/user',
function(request,response)
{
  connection.acquire(
  function(err,con)
  {
    console.log('user/pass request processing');
    //console.log(request.body);
    let token = "";
    let user_id = -1;
    con.query('SELECT * FROM users',
    function(err, rows, fields)
    {
      let needsResponse = true;
      for(let i = 0; i < rows.length; i++)
      {
        if (rows[i].username == request.body.username)
        {
          if (rows[i].password == request.body.password)
          {
            user_id = rows[i].id;
            let isInArray = true;
            do
            {
              token = makeTokenData();
              isInArray = false;
              activeTokensArray.forEach(function(tokenArray)
              {
                if(tokenArray[1] == token)
                {
                  isInArray = true;
                };
              })
              console.log("looping")
            }
            while (isInArray);
            activeTokensArray.push([user_id, token]);
            response.send({"token":token});
            console.log("Sent Token Response")
            needsResponse = false
            con.release();
          }//end if pass
        }//end if user
      }//end for
      if(needsResponse)
      {
        response.send({"token":null});
        console.log("Sent Empty Response")
      }
    })
    if (token != "")
    {
      con.query('INSERT INTO tokens VALUES (null,?)',[token],
      function(err, rows, fields)
      {
        con.release();
      });
    }
  });
});

// GET call to retrieve plans table
app.get ('/plans', function (request, response)
{
  console.log("Plans Entered")
  let validToken = false;
  activeTokensArray.forEach(function(tokenArray)
  {
    tokenArray[1].replace("'", "");
    if (tokenArray[1] == request.query.token)
    {
      validToken = true;
    }
  })
  if (validToken)
  {
    connection.acquire(function(err, con)
    {
      con.query('SELECT id, name, rate, description, image FROM plans',
      function(err, rows, fields)
      {
        console.log('sending plans');
        response.send({plans: rows});
        con.release();
      })//end query&function
    });//end connection.acquire&function
  }
  else
  {
      console.log("Invalid token, empty plans sent");
      console.log(request.query.token);
      console.log(activeTokensArray);
      console.log("Plans query token and active tokens array")
      response.send({plans: null});
  }//end if active token
});

// GET call to retrieve scheduled_visits table
app.get ('/scheduled_visits', function (request, response)
{
  let validToken = false;
  activeTokensArray.forEach(function(tokenArray)
  {
    tokenArray[1].replace("'", "");
    if (tokenArray[1] == request.query.token)
    {
      validToken = true;
    }
  })
  if (validToken)
  {
    connection.acquire(function(err, con)
    {
      con.query('SELECT id, tech_id, date, user_id, time, plan_id FROM scheduled_visits',
      function(err, rows, fields)
      {
        console.log('sending scheduled_visits');
        response.send({scheduled_visits: rows});
        con.release();
      })
    });
  }
  else
  {
      console.log("Invalid token, empty scheduled_visits sent");
      console.log(request.query.token);
      console.log(activeTokensArray);
      console.log("scheduled_visits query token and active tokens array")
      response.send({scheduled_visits: null});
  }//end if active token
});

// GET call to retrieve techs table
app.get ('/techs', function (request, response)
{
  console.log(request.socket.id);
  let validToken = false;
  activeTokensArray.forEach(function(tokenArray)
  {
    tokenArray[1].replace("'", "");
    if (tokenArray[1] == request.query.token)
    {
      validToken = true;
    }
  })
  if (validToken)
  {
    connection.acquire(function(err, con)
    {
      con.query('SELECT id, name FROM techs',
      function(err, rows, fields)
      {
        console.log('sending techs');
        response.send({techs: rows});
        con.release();
      })
    });
  }
  else
  {
      console.log("Invalid token, empty techs sent");
      console.log(request.query.token);
      console.log(activeTokensArray);
      console.log("techs query token and active tokens array")
      response.send({techs: null});
  }//end if active token
});

// POST call to add a headline into a newsgroup
app.post('/plans', function(request, response)
{
  connection.acquire(function(err, con)
  {
    console.log(request.body)
    con.query('INSERT INTO plans VALUES (null,?,?,?,?)' , [request.query.name, request.query.rate, request.query.description, request.query.image], function(err, rows, fields)
    {
      response.send({message: "record inserted"});
      con.release();
    })
  });
});

// POST call to add a headline into a newsgroup
app.post('/scheduled_visits', function(request, response)
{
  connection.acquire(function(err, con)
  {
    console.log("Posting to scheduled_visits, printing request.body")
    console.log(request.body)
    con.query('INSERT INTO scheduled_visits VALUES (null,?,?,?,?,?)' , [request.body.tech_id, request.body.date, request.body.user_id, request.body.time, request.body.plan_id],
    function(err, rows, fields)
    {
      console.log(request.body.tech_id, request.body.date, request.body.user_id, request.body.time, request.body.plan_id);
      response.send({message: "record inserted"});
      con.release();
      emitVisitEvent();
    })
  });
});

function emitVisitEvent()
{
  let connectedSocketsToEmit = io.sockets.connected;
  console.log(connectedSocketsToEmit);
  socketClientsArray.forEach(function(connectedSocket)
  {
    connectedSocketsToEmit[connectedSocket.socketid].emit('scheduled_visits_updated')
  })
}

/*

// POST call to add a headline into a newsgroup
app.post('/headline', function(request, response) {
connection.acquire(function(err, con)
    {
     con.query('INSERT INTO headlines VALUES (null,?,?)' , [request.query.newsgroup, request.query.headline], function(err, rows, fields)
      {
      		response.send({message: "record inserted"});
          	con.release();
          	emitHeadlineEvent();
         })
      });
});

// check to see if a connected token is inside a usergroup, if so emit an update that headline has been updated
function emitHeadlineEvent()
{
	connection.acquire(function(err, con)
  {
    // query to see the tokens associated with users that are in a newsgroup
     con.query('SELECT DISTINCT user_id, users.token FROM user_newsgroups JOIN users ON user_newsgroups.user_id = users.userID' , function(err, rows, fields)
      {
      		let headlineTokensArray = [];
      		let connectedTokensArray = [];
      		let connectedSocketsArray = [];
      		let socketsToGetEventArray = [];

      		rows.forEach(function(value)
      		{
      			// put query values into an array to compare with tokens that are connected
      			headlineTokensArray.push (value.token);
      		})
      		con.release(); // release database connection while we iterate through the arrays

      		socketClientsArray.forEach(function(value)
    			{
    				connectedSocketsArray.push (value.socketid);
    				connectedTokensArray.push (value.token);
    			});

      		// now compare headline tokens from database to those client tokens that are connected with a live socket
      		let connectionsToReceiveArray = connectedTokensArray.filter((n) => headlineTokensArray.includes(n))

      		connectionsToReceiveArray.forEach(function(value)
    			{
    				socketClientsArray.forEach(function(socket_value)
    				{
    					//if there is a match on the token, loop through the connection objects to get the socketID
    					if (value == socket_value.token)
    					{
    						// check this is a connected socketID
     						if (io.sockets.connected[socket_value.socketid])
          					{
          						// if checks out that this is a connected socket emit the event to socketID
       			 				io.sockets.connected[socket_value.socketid].emit('headlines_updated');
    						};

    						// print to console current socket being emitted to
    						console.log (socket_value.socketid);
    					}
    				})
    			});
    })
  });
};*/


// event called on Socket.IO connection
io.on('connect', function(client)
{
	// incoming parameters
	let clientID = client.id;
	let token = client.handshake.query.token;
	console.log ("connected: " + client.id); // print to console the incoming socket ID

	// remove any existing socket connections from array that are
	// different than the incoming token

	for (let i = 0; i < socketClientsArray.length; i++)
	{
    if (socketClientsArray[i].token == token)
 		{
 			if (i > -1)
 			{
        socketClientsArray.splice(i, 1);
			};
		};
	};

	// create an object with the socketID and the token that's associated with
	let clientConnection = {};
	clientConnection.socketid = clientID;
	clientConnection.token = token;
	socketClientsArray.push(clientConnection);
})

io.on('disconnect', function(client){
  console.log("Client "+client.id+" Disconnected")
})

socketserver.listen(8080); // Socket.IO, port 8080
app.listen (3000); // API, port 3000

function makeTokenData()
{
  let data = "";
  let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (let i = 0; i < 64; i++)
    data += possible.charAt(Math.floor(Math.random() * possible.length));

  return data;
}
