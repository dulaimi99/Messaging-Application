import QtQuick 2.0
import QtQml 2.12
import QtQuick.Controls 2.12

Item{

    id: messaging_interface_container
    height: parent.height
    width: parent.width
    anchors.fill:parent

    //list model for chat transcripts
    property alias script_list: texts_list
    //list model for online users list
    property alias ou_list: online_users_list
    //list view for online users
    property alias  ou_list_view: online_users_list_view
    // Conversation title text
    property alias conversation_title_text: conversation_title.text

    //emitted when message is sent
    signal send(string text_msg)
    //emitted when an online user is clicked
    signal user_clicked(string username)

    //View of the users online
    Column{
        id: online_users_view
        height: parent.height * 0.95
        width: parent.width * 0.20
        spacing: 3
        anchors{
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        Rectangle{
            id : ou_title_container
            height: parent.height * 0.075
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            radius: 3

            Text {
                id: online_users_title
                text: qsTr("Online Users")
                font.pixelSize: 15
                font.bold: true
                font.family: "Corbel"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                color: "#4682b4"
            }
        }


        ScrollView{
            id: online_users_scroll_view
            width: parent.width
            height: parent.height * 0.80
            anchors.margins: 5

            //online users list model
            ListModel{
                id: online_users_list
            }

            Component{
                id:online_users_delegate
                Rectangle{
                    id: online_username_container
                    width: online_users_view.width * 0.90
                    height: 25
                    color: "#4682b4"
                    border.color: "#4682b4"
                    radius: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    property alias text_color: user_name_text.color


                    Text {
                        id: user_name_text
                        text: username
                        font.pixelSize: 14
                        font.family: "Corbel"
                        color: "white"
                        anchors{
                            centerIn: parent
                        }
                    }

                    MouseArea{
                        id: online_user_clickable
                        anchors.fill: parent
                        //emit user clicked signal. Handled in main.qml
                        onClicked: messaging_interface_container.user_clicked(user_name_text.text)
                        cursorShape: "PointingHandCursor"
                    }
                }
            }
            //online users list view
            ListView{
                id: online_users_list_view
                model: online_users_list
                delegate: online_users_delegate
                clip: true
                layoutDirection: "LeftToRight"
                verticalLayoutDirection: "TopToBottom"
                highlightFollowsCurrentItem: true
                currentIndex: -1
                anchors.fill: parent
                spacing: 3

            }
        }
    }

    //Chat area view
    Column{

        id: conversation_area_column
        height: parent.height * 0.95
        width: parent.width * 0.75
        anchors.left: online_users_view.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5

        spacing: 3

        //Conversation title. Depends on who the user is sending messages to
        Rectangle{
            id:conversation_title_container
            width: parent.width
            height: parent.height * 0.075
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#4682b4"
            radius : 3


            Text {
                id: conversation_title
                text: qsTr("Broadcast")
                font.pixelSize: 15
                font.bold: true
                font.family: "Corbel"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //Conversations transcripts box
        Rectangle
        {
            id: convo_box
            color: "white"
            height: parent.height * 0.8
            width: parent.width
            border.color: "#4682b4"
            border.width: 1
            radius: 3


            ScrollView{
                id: chat_transcript_scrollview
                width: parent.width
                height: parent.height
                anchors.fill: parent
                clip: true

                //chat transcript list model
                ListModel
                {
                    id: texts_list

                }

                Component{
                    id:list_delegate

                    Rectangle{
                        width: text_content.width + 10
                        height: text_content.height + 5
                        anchors.right: sender === "Me" ? parent.right : undefined;
                        radius : 4
                        color: sender === "Me"? "#4682b4" : "#D0D0D0";




                        TextEdit {
                            id: text_content
                            text: sender === "Me" ? content : sender + " : " + content;
                            textFormat: Text.RichText
                            readOnly: true
                            font.pixelSize: 15
                            font.family: "Corbel"
                            color: "white"
                            anchors{
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }

                            wrapMode: TextEdit.Wrap

                        }
                    }
                }

                //chat transcript list view
                ListView{
                    id: texts_list_view
                    layoutDirection: "LeftToRight"
                    verticalLayoutDirection: "TopToBottom"
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    model: texts_list
                    delegate: list_delegate
                }
            }
        }

        //Chat box and send button
        Row
        {
            id: texting_area
            width: parent.width
            height: parent.height * 0.1
            spacing: 3

            //chat box
            Rectangle
                    {
                        id: chat_box
                        width: parent.width * 0.80
                        height: parent.height
                        color:"white"
                        border.color: "#4682b4"
                        radius: 3


                            TextInput{
                                id: text_input
                                text: ""
                                anchors.fill: parent
                                wrapMode: Text.WrapAnywhere
                                clip: true
                                anchors.margins: 4
                                color: focus? "#4682b4" : "gray"
                                font.pixelSize: 15
                                font.family: "Corbel"
                                onAccepted: {
                                    texts_list.append({
                                                          "sender" : "Me",
                                                          "content" : text_input.text
                                                      })
                                    //Emit send signal. Signal handled in main.qml
                                    messaging_interface_container.send(text_input.text)

                                    text_input.text = ""
                                }

                            }
                        }

            //send button
            Rectangle
            {
                id: send_box
                width: parent.width * 0.20
                height: parent.height
                color:"#4682b4"
                radius: 3

                Text {
                    id: send_button_text
                    text: qsTr("Send")
                    color: "white"
                    anchors.centerIn: parent
                    font.pixelSize: 15
                    font.family: "Corbel"
                    font.bold: true
                }

                MouseArea{
                    id: send_button
                    anchors.fill: parent
                    cursorShape: "PointingHandCursor"
                    onClicked: {
                        texts_list.append({
                                              "sender" : "Me",
                                              "content" : text_input.text
                                          })

                        //Emit send signal. Signal handled in main.qml
                        messaging_interface_container.send(text_input.text)

                        text_input.text = ""
                    }

                }
            }
        }
    }
}
