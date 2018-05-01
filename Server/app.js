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

let express = require('express')
let mysqlConnection = require('./connection')
let bodyParser = require ('body-parser')
//let app = express();
let socketserver = require('http').createServer()
let io = require('socket.io')(socketserver)
let socketClientsArray = [];
var print = console.log.bind(console)
var didEmit = false

mysqlConnection.init();

io.on('connect', function(client)
{
	// incoming parameters
	socketClientsArray.push(client)
	let clientID = client.id;
	let token = client.handshake.query.token;
  if (token == "nil")
  {
    print("connected: " + client.id)
  }
  else
  {
      print("connected: " + client.id +" with "+ token)
  }
})

io.on('connection', function(client)
{
  client.on('disconnect', function(date)
  {
    print("Client "+client.id+" Disconnected: "+date)
  })

  client.on('plans_request', function(data)
  {
    print("Plans REquest Triggered")
  	let clientID = client.id;
  	let token = client.handshake.query.token;
    if(validateSocket(clientID, token) == true)
    {
      mysqlConnection.acquire(function(err,con)
        {
          con.query('SELECT id, name, rate, description, image FROM plans', function(err, table_rows, fields)
          {
            client.emit('plans_data', {'plans':table_rows})
          })
					con.release()
        })//end mysqlConnection.acquire(function(err,con)
    }// end if
    else
    {
      client.emit('needs_new_token')
    }//end if(validateSocket(clientID, token) == true) else
  })//end client.on('plans_request', function()

  client.on('techs_request', function(data)
  {
    print("Techs REquest Triggered")
  	let clientID = client.id;
  	let token = client.handshake.query.token;
    if(validateSocket(clientID, token) == true)
    {
      mysqlConnection.acquire(function(err,con)
        {
          con.query('SELECT id, name FROM techs', function(err, table_rows, fields)
          {
            client.emit('techs_data', {'techs':table_rows})
          })
					con.release()
        })//end mysqlConnection.acquire(function(err,con
    }//end if
    else
    {
      client.emit('needs_new_token')
    }//end if(validateSocket(clientID, token) == true) else
  })//end client.on('techs_request', function()

  client.on('users_request', function(data)
  {
    print("Users REquest Triggered")
    let parsedData = JSON.parse(data.toString())
    let clientID = client.id;
    let token = client.handshake.query.token;
    if(validateSocket(clientID, token) == true)
    {
      mysqlConnection.acquire(function(err,con)
        {
          con.query('SELECT id, first_name, last_name, username, plan_id, street_address, city_state_zip, active, number FROM users WHERE id = ?', [parsedData.id.toString()], function(err, table_rows, fields)
          {
            print("\n\nsending user data for ID: "+parsedData.id+"\n")
            print(table_rows)
            client.emit('users_data', {'users':table_rows})
          })//end con.query(
					con.release()
        })//end mysqlConnection.acquire(function(err,con)
    }//end if
    else
    {
      client.emit('needs_new_token')
    }//end if(validateSocket(clientID, token) == true) else
  })//end client.on('users_request', function()

	client.on('update_user', function(data)
	{
		print('update user triggered')
		let clientID = client.id;
		let token = client.handshake.query.token;

		if (validateSocket(clientID, token) == true)
		{
	    let parsedData = JSON.parse(data)
			print(parsedData.password.toString())
			parsedData.password = caesar.decode(parsedData.password)
			print(parsedData.password.toString())
			// UPDATE mytable
		  //   SET column1 = value1,
		  //       column2 = value2
		  //   WHERE key_value = some_value;
			mysqlConnection.acquire(function(err,con)
			{
				con.query('UPDATE users SET first_name = ?, last_name = ?, username = ?, password = ?, plan_id = ?, street_address = ?, city_state_zip = ?, active = ?, number = ? WHERE id = ?',[parsedData.first_name, parsedData.last_name, parsedData.username, parsedData.password, parsedData.plan_id, parsedData.street_address, parsedData.city_state_zip, parsedData.active, parsedData.number, parsedData.id], function(err, table_rows, fields)
				{
					if (err != null)
					{
						print(err)
					}
					print(table_rows, fields)
					if(didEmit != true)
					{
						didEmit = true;
						client.emit('needs_new_token')
					}
				})
				con.release()
			})
		}
		else
		{
			client.emit('needs_new_token')
		}
		didEmit = false;
	})

	client.on('new_user', function(data)
	{
		print('****new user triggered')
		let clientID = client.id;
		let token = client.handshake.query.token;

    let parsedData = JSON.parse(data)
		print(parsedData.password.toString())
		parsedData.password = caesar.decode(parsedData.password)
		print(parsedData.password.toString())
		// UPDATE mytable
	  //   SET column1 = value1,
	  //       column2 = value2
	  //   WHERE key_value = some_value;
		mysqlConnection.acquire(function(err,con)
		{
			con.query('INSERT INTO users VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [parsedData.first_name, parsedData.last_name, parsedData.username, parsedData.password, parsedData.plan_id, parsedData.street_address, parsedData.city_state_zip, parsedData.active, parsedData.number], function(err, table_rows, fields)
			{
				if (err != null)
				{
					print(err)
				}
				print(table_rows, fields)
				if(didEmit != true)
				{
					didEmit = true;
					client.emit('needs_new_token')
				}
			})
			con.release()
		})

		didEmit = false;
	})

  client.on('scheduled_visits_request', function(data)
  {
    print("Visits REquest Triggered")
    let clientID = client.id;
    let token = client.handshake.query.token;
    if(validateSocket(clientID, token) == true)
    {
      mysqlConnection.acquire(function(err,con)
        {
          con.query('SELECT * FROM scheduled_visits', function(err, table_rows, fields)
          {
            client.emit('scheduled_visits_data', {'scheduled_visits':table_rows})
						print("client.emit('scheduled_visits_data', {'scheduled_visits':table_rows}) ran")
          })
					con.release()
        })//end mysqlConnection.acquire(function(err,con)
    }//end if
    else
    {
      client.emit('needs_new_token')
    }//end if(validateSocket(clientID, token) == true) else
  })//end client.on('scheduled_visits_request', function(data)

  client.on('user_pass_req',function(data)
  {
    print("Entered client.on('user_pass_req',function(data)")
    let parsedData = JSON.parse(data)
    print('parsed data: ', parsedData)
    let username = parsedData.user;
    print('username: ', username)
    let password = caesar.decode(parsedData.pass);
    print('password: ', password)
    mysqlConnection.acquire(function(err,con)
      {
				print("mysqlConnection acquired: beginning processing of user/pass request")
        if (err != null)
        {
          print(err)
        }
        //console.log(request.body);
        let token = "";
        let rows;
        con.query('SELECT * FROM users', function(err, table_rows, fields)
        {
          rows = table_rows;
          let emitError = true;
          for(let i = 0; i < rows.length; i++)
          {
            if (rows[i].username == username)
            {
              if (rows[i].password == password)
              {
                emitError = false;
                token = makeTokenData();

                print("Sent Token Response")
                client.emit("reconnect_with_token", {'token':token, 'id':rows[i].id})
              }//end if pass
            }//end if user
          }//end for
          if(emitError)
          {
            print("Incorrect auth, emitting error")
            client.emit("incorrect_auth")
          }

          con.release()
        })
      })
  })

  client.on('add_scheduled_visit', function(data)
  {
    print("Add Scheduled Visit REquest Triggered")
    let parsedData = JSON.parse(data.toString())
		print(parsedData)
  	let clientID = client.id;
  	let token = client.handshake.query.token;
    if(validateSocket(clientID, token) == true)
    {
      mysqlConnection.acquire(function(err,con)
        {
          con.query('INSERT INTO scheduled_visits VALUES (null,?,?,?,?,?)',[parsedData.tech_id ,parsedData.date, parsedData.user_id, parsedData.time, parsedData.plan_id], function(err, table_rows, fields)
          {
            emitVisitsNeedUpdate()
						print("emitVisitsNeedUpdate() ran")
          })
					con.release()
        })//end mysqlConnection.acquire(function(err,con)
    }// end if
    else
    {
      client.emit('needs_new_token')
    }//end if(validateSocket(clientID, token) == true) else
  })//end client.on('plans_request', function()
})

var caesar =
{
	valArray : [84, 104, 101,
									97, 32, 65,
									117, 103, 117,
									115, 116, 97,
									32, 80, 97,
									117, 108, 101,
									116, 116, 101,
									32, 83, 116,
									114, 105, 110, 101],
	decode : function(password)
		{
			return caesar.code(password, true)
		},//end decode function
	encode : function(password)
		{
			return caesar.code(password, false)
		},//end encode function
	code : function(password, decode)
		{
			let codedString = "";

			let val;
			for(let i = 0; i < password.length; i++)
			{
				if(i >= caesar.valArray.length)
				{
					val = caesar.valArray[i%caesar.valArray.length];
				}
				else
				{
					val = caesar.valArray[i];
				}
				if(decode)
				{
					val = -Math.abs(val);
				}
				codedString += String.fromCharCode(parseInt((password.charAt(i).charCodeAt(0)+val).toString(16), 16))
			}
			return codedString
		}//end code function
}

function emitVisitsNeedUpdate()
{
	print("ENTERED")
  io.emit('scheduled_visits_updated')
	print("emitted for all sockets")
}

function makeTokenData()
{
  let data = "";
  let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

  for (let i = 0; i < 64; i++)
    data += possible.charAt(Math.floor(Math.random() * possible.length));

  return data;
}

function validateSocket(clientID, token)
{
  let activeSockets = io.sockets.connected;
  print(activeSockets+"")
  print(activeSockets[clientID]+"")
  print(clientID)
  if (clientID in activeSockets)
  {
    let socket = activeSockets[clientID];
    if (socket.id == clientID)
    {
      print("Found matching socket:"+socket.toString())
      print("Checking Token:"+socket.handshake.query.token.toString())
      if(socket.handshake.query.token == token)
      {
        return true;
      }//end if(socket.handshake.query.token == token)
    }//end if (socket.id == clientID)
  }//end if
  else
  {
    return false;
  }//end if (clientID in activeSockets) else\
}

socketserver.listen(8080); // Socket.IO, port 8080
//app.listen (3000); // API, port 3000

/* 90% my code
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
    mysqlConnection.acquire(
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

//not sure why this has to be POST
//post? call to validate user/pass combination
app.post ('/user',
function(request,response)
{
  mysqlConnection.acquire(
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
    mysqlConnection.acquire(function(err, con)
    {
      con.query('SELECT id, name, rate, description, image FROM plans',
      function(err, rows, fields)
      {
        console.log('sending plans');
        response.send({plans: rows});
        con.release();
      })//end query&function
    });//end mysqlConnection.acquire&function
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
    mysqlConnection.acquire(function(err, con)
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
    mysqlConnection.acquire(function(err, con)
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

app.post('/plans', function(request, response)
{
  mysqlConnection.acquire(function(err, con)
  {
    console.log(request.body)
    con.query('INSERT INTO plans VALUES (null,?,?,?,?)' , [request.query.name, request.query.rate, request.query.description, request.query.image], function(err, rows, fields)
    {
      response.send({message: "record inserted"});
      con.release();
    })
  });
});

app.post('/scheduled_visits', function(request, response)
{
  mysqlConnection.acquire(function(err, con)
  {
    console.log("Posting to scheduled_visits, printing request.body")
    console.log(request.body)
    con.query('INSERT INTO scheduled_visits VALUES (null,?,?,?,?,?)' , [request.body.tech_id, request.body.date, request.body.user_id, request.body.time, request.body.plan_id],
    function(err, rows, fields)
    {
      console.log(request.body.tech_id, request.body.date, request.body.user_id, request.body.time, request.body.plan_id);
      response.send({message: "record inserted"});
      con.release();
      emitVisitsNeedUpdate();
    })
  });
});*/
