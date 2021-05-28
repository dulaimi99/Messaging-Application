import QtQuick 2.12
import QtQuick.Window 2.12
import QtWebSockets 1.1
import QtQuick.Controls 2.12
import QtQml 2.12
import back_end_module 1.0


Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Chat Coding Challenge")


    Loader{
        id: page_loader
        anchors.fill: parent
        source: "Login.qml"
    }

    // C++ backend
    BackEnd{
        id: back_end

    }



    Connections{
        target: page_loader.item
        ignoreUnknownSignals: true
        onSubmit: {

            //extract requested username
            var requested_username = page_loader.item.user_name_text

            //send requested username to server
            var msg ={
                "msg_type": "sign_in_request",
                "requested_username": requested_username
            }
            socket.sendTextMessage(JSON.stringify(msg))
        }

        //on text sent
        onSend: {

            //online users list model and list view
            var list_model = page_loader.item.ou_list
            var list_view = page_loader.item.ou_list_view

            //receiver of text message
            var receiver_index = list_view.currentIndex

            //No users are selected for messaging
            //messaging interface in broadast mode
            if (receiver_index === -1){

                var msg = {
                    msg_type : "broadcast",
                    sender : back_end.username,
                    text_message : text_msg
                }


                //add to conversations list
                back_end.add_to_broadcast_list("Me",text_msg)
            }

            else{

                var receiver_name = list_model.get(receiver_index).username

                //construct message w text information
                msg = {
                    msg_type: "text_message",
                    sender: back_end.username,
                    receiver: receiver_name,
                    text_message: text_msg
                }

                //add to conversations list
                back_end.add_to_convo_list(receiver_name,"Me",text_msg)
            }

            //send text message to server
            socket.sendTextMessage(JSON.stringify(msg))
        }
        //user clicked signal. Load converation with clicked user
        onUser_clicked:{

            //online users list model & view
            var ou_list_model = page_loader.item.ou_list
            var ou_list_view = page_loader.item.ou_list_view

            //conversation script list model
            var conversation_list_model = page_loader.item.script_list

            //find position of clicked user's list item and change it's color to blue
            var index = back_end.online_users.indexOf(username)

            //messaging interface displaying conversations with a specific user
            if (ou_list_view.currentIndex !== -1)
            {
                //user clicked on is the active ongoing conversation
                //unselect user and switch to displaying broadcast conversation
                if(index === ou_list_view.currentIndex){

                    //unselect user
                    ou_list_view.currentItem.color = "#4682b4"
                    ou_list_view.currentItem.text_color = "white"

                    //update conversation title text to "Broadcast"
                    page_loader.item.conversation_title_text = "Broadcast"

                    //set online user's list view current index to -1
                    ou_list_view.currentIndex = -1

                    //load broadcast conversation to display
                    var i;
                    var broadcast_list = back_end.broadcast_conversation_list;

                    //clear existing text bubbles
                    conversation_list_model.clear()

                    //load saved broadcast conversation script
                    for(i = 0; i< broadcast_list.length; ++i)
                    {
                        conversation_list_model.append({"sender" : broadcast_list[i].sender, "content" : broadcast_list[i].text_msg })
                    }
                }

                //user clicked on is not the active ongoing conversation
                //update to newly selected user to become the active
                //ongoing conversation
                else{

                    //unselect previous user
                    ou_list_view.currentItem.color = "#4682b4"
                    ou_list_view.currentItem.text_color = "white"

                    //Set clicked user as current item
                    ou_list_view.currentIndex = index
                    ou_list_view.currentItem.color = "white"
                    ou_list_view.currentItem.text_color = "#4682b4"

                    //update conversation title text to the user's name
                    page_loader.item.conversation_title_text = username



                    //clear current chat transcript
                    conversation_list_model.clear()

                    //load chat transcript with new clicked user
                    var chat_transcript = back_end.conversations_list(username)

                    //load saved broadcast conversation script
                    for(i = 0; i< chat_transcript.length; ++i)
                    {
                        conversation_list_model.append({"sender" : chat_transcript[i].sender, "content" : chat_transcript[i].text_msg })
                    }

                }
            }

            //messaging interface in broadcast mode
            //switch to specific user messaging mode
            else{

                //Set newly clicked user as active ongoing conversation
                ou_list_view.currentIndex = index
                ou_list_view.currentItem.color = "white"
                ou_list_view.currentItem.text_color = "#4682b4"

                //update conversation title text to the user's name
                page_loader.item.conversation_title_text = username

                //clear current chat transcript
                conversation_list_model.clear()


                //load chat transcript with clicked user
                chat_transcript = back_end.conversations_list(username)


                //load saved broadcast conversation script
                for(i = 0; i< chat_transcript.length; ++i)
                {
                    conversation_list_model.append({"sender" : chat_transcript[i].sender, "content" : chat_transcript[i].text_msg })
                }
            }
        }
    }


    WebSocket{
        id:socket
        active: true
        url: "ws://localhost:8080"

        //Received text message from websocket server
        onTextMessageReceived: function(message){

            //parse message
            var msg = JSON.parse(message)

            //online users list and list view
            var ou_list_view;
            var ou_list;

            //response to the username request
            if(msg.msg_type === "sign_in_request_response")
            {

                if(msg.response === "accepted")
                {
                    //assign username
                    back_end.username = msg.requested_username

                    //load messaging interface
                    page_loader.source = "MessagingInterface.qml"

                    // online users list and list view
                    ou_list_view = page_loader.item.ou_list_view
                    ou_list = page_loader.item.ou_list

                    //set backend users list
                    back_end.online_users = msg.online_users_list

                    //populate online users column with names of online users
                    back_end.online_users.forEach(function each(user){
                        ou_list.append({ "username" : user})
                    })

                    //construct sign-in message to send to server
                     var sign_in_msg = {
                        username: back_end.username,
                        msg_type: "sign-in",
                    }

                    //Send sign-in message
                    socket.sendTextMessage(JSON.stringify(sign_in_msg))
                }

                //username is taken
                else{
                    page_loader.item.invalid_username.open()
                }

            }

            //new user online nontification
            else if (msg.msg_type === "user_online")
            {
                ou_list_view = page_loader.item.ou_list_view
                ou_list = page_loader.item.ou_list

                //load another one
                //create list of online users to append to online users view
                //back_end.online_users = msg.online_users_list

                back_end.add_user(msg.username)

                if (ou_list)
                {
                    ou_list.append({"username" : msg.username})
                 }
            }

            //text message notification
            else if(msg.msg_type === "text_message")
            {   
                ou_list_view = page_loader.item.ou_list_view
                ou_list = page_loader.item.ou_list

                //update backend conversations list
                back_end.add_to_convo_list(msg.sender,msg.sender,msg.text_message)

                //if messaging interface is currently displaying conversation
                //with sender, append text message to script_list
                var index = back_end.online_users.indexOf(msg.sender)

                if (index === ou_list_view.currentIndex)
                {
                    //update convo view
                    page_loader.item.script_list.append({
                                          "sender" : msg.sender,
                                          "content" : msg.text_message
                                      })
                }
            }

            //text message notification
            else if(msg.msg_type === "broadcasted_msg")
            {
                ou_list_view = page_loader.item.ou_list_view
                ou_list = page_loader.item.ou_list

                //update backend conversations list
                back_end.add_to_broadcast_list(msg.sender,msg.text_message)

                //add text message to text list view if
                //messaging interface in broadcast mode
                if(ou_list_view.currentIndex === -1)
                {
                    //update conversation view
                    page_loader.item.script_list.append({
                                          "sender" : msg.sender,
                                          "content" : msg.text_message
                                      })
                }

            }

            else if (msg.msg_type === "user_disconnected")
            {
                //online users list model and list view
                ou_list_view = page_loader.item.ou_list_view
                ou_list = page_loader.item.ou_list

                //remove from online users view
                if (ou_list)
                {
                    ou_list.remove(back_end.online_users.indexOf(msg.username))
                }

                //remove from backend user's list and saved conversations
                back_end.remove_user(msg.username)
                back_end.remove_from_convo_list(msg.username)
            }
        }
    }
}
