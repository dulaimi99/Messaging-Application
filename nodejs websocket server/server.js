const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

//online users list
var online_users = []

//object to store usernames and corresponding websocket connection object
var online_users_connections = {}

//broadcast message function
function broadcast(ws,msg){

  wss.clients.forEach(function each(client) {
    if ( ws !== client && client.readyState === WebSocket.OPEN) {
        //send notification
        client.send(JSON.stringify(msg))
    }
  })
}

//return username of a given ws
function getUsernameByValue(ws) {
  return Object.keys(online_users_connections).find(key => online_users_connections[key] === ws);
}

//connection made to server. New user online
wss.on('connection', function connection(ws) {
   
  //message received from a user
  ws.on('message', function incoming(data) {
    
    //parse json message from app
    msg = JSON.parse(data)
    
    //sign-in/username request
    if (msg.msg_type === "sign_in_request"){
      
      // extract requested username from message
      requested_username = msg.requested_username

      var response = {
        "msg_type" : "sign_in_request_response",
      }
      
      //username taken. Reject sign-in
      if(online_users.includes(requested_username))
      {
        response["response"] = "denied"
        ws.send(JSON.stringify(response))
      }

      //username accepted. Sign user in and broadcast new user to other users
      else{
        
        //configure response 
        response["response"] = "accepted"
        response["requested_username"] = requested_username
        response["online_users_list"] = online_users

        ws.send(JSON.stringify(response))

        //add username to online users list
        online_users.push(requested_username)

        //add user's websocket to user-websocket object
        online_users_connections[requested_username] = ws 

        //broadcast new user to signing on to all other online users
        user_online = {
          "msg_type" : "user_online",
          "username" : requested_username
        }
        broadcast(ws,user_online)
      }    
    }

    //text message notification
    else if (msg.msg_type === 'broadcast'){
        
      broadcast_json = {
        msg_type: "broadcasted_msg",
        sender: msg.sender,
        text_message: msg.text_message
      }

      //broadcast
      broadcast(ws,broadcast_json)
    }

    //text message notification
    else if (msg.msg_type === 'text_message'){
        
      text_msg_json = {
        msg_type: "text_message",
        sender: msg.sender,
        receiver: msg.receiver,
        text_message: msg.text_message
      }
      
      //send message to receiver
      online_users_connections[msg.receiver].send(JSON.stringify(text_msg_json))
      
    }
  })
  
  //user disconnecting. update other users
  ws.on('close', function user_disconnecting(){
    
    
    //username of disconnecting user
    username = getUsernameByValue(ws)
    
    //user never signed in
    if (username === undefined)
      return ;

    //remove user from online users list
    //and online users connections object 
    index = online_users.indexOf(username)
    online_users.splice(index,1)
    delete online_users_connections.username 

    //msg JSON
    broadcast_json = {
      username: username,
      msg_type: "user_disconnected",
      online_users_list: online_users
    }
    
    //notify other users of user disconnecting
    broadcast(ws,broadcast_json)

  });
});
