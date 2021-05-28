#include "backend.h"
#include <QDebug>
#include <stdio.h>

using namespace std;
//constructor
BackEnd::BackEnd(QObject *parent) : QObject(parent) {}

//Getter for user's name
QString BackEnd:: username()
{
    return my_username;

}

// Setter for user name
void BackEnd::set_username(const QString &new_username){

    //assign username
    my_username = new_username;
}

//return list of online users
QVariantList BackEnd::online_users()
{
    return online_users_list;
}

//create list of currently online users
void BackEnd::set_ou_list(QVariantList ou_list){

    //set list
    online_users_list = ou_list;

}

//new user online. Add him to online users list
void BackEnd::add_user(QString username){

    //add username to online users list
    online_users_list.append(username);

}

//User logged off. Remove them from online users list
void BackEnd::remove_user(QString username){

    //remove username from online users list
    online_users_list.removeOne(username);
}

//update conversations list
void BackEnd::add_to_convo_list(QString username,QString sender, QString text_message)
{
    //create qmap of text. key: sender, value: text message
    QVariantMap text;

    //add sender and text message info to map
    text["sender"] = sender;
    text["text_msg"] = text_message;


    //create temporary conversation list
    QVariantList convo_list;

    //conversation list between application and sender are empty
    if(!conversations[username].toList().size()){

        //add new text to convo list
        convo_list.append(text);

        //add convo list to conversations map
        conversations[username] = convo_list;
    }

    //there is an already existing convo list
    else{
        //append new text to conversation list
        convo_list = conversations[username].toList();
        convo_list.append(text);
        conversations[username] = convo_list;
    }
}

//remove offline user from list of conversation
void BackEnd::remove_from_convo_list(QString username)
{
    conversations.remove(username);
}

//return conversations list
QVariantList BackEnd::conversations_list(QString username){
    return conversations[username].toList();
}


//add text message to broadcast list
void BackEnd::add_to_broadcast_list(QString sender, QString text_message)
{
    //create qmap of text. key: sender, value: text message
    QVariantMap text;

    //add sender and text message info to map
    text["text_msg"] = text_message;
    text["sender"] = sender;

    //append tp broadcast list
    broadcast_list.append(text);


}

//return broadcast chat transcript
QVariantList BackEnd::broadcast_conversation()
{
    return broadcast_list;
}






