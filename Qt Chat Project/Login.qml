import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

Rectangle {
    id: login_container
    anchors
    {
        verticalCenter: parent.verticalCenter
        horizontalCenter: parent.horizontalCenter
        margins: 2

    }

    color: "#4682b4"

    //selected username text
    property alias user_name_text: username_input.text
    //invalid username alert
    property alias invalid_username: invalid_username_alert
    //emitted when user submits a username
    signal submit(string user_name)

    //alert user when they have chosen
    //a username that has been taken
    MessageDialog{
        id: invalid_username_alert

        title: "Invalid Username"
        text: "Username taken. Try a different one!"
        standardButtons: StandardButton.Ok
        onYes: invalid_username_alert.close()

    }

    //Text requesting user to enter a username
    Text {
        id: name_prompt
        text: qsTr("Select Username")
        font.family: "Corbel"
        color: "white"
        font.pixelSize: 19
        font.bold: true
        anchors.bottom: user_name_container.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5

    }

    Rectangle{
        id:user_name_container
        width: parent.width * 0.30
        height: parent.height * 0.05
        border.width: 1
        border.color: "#4682b4"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5
        radius: 4

        //textinput for user to enter a username
        TextInput{
            id: username_input
            text: ""
            anchors.fill: parent
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            wrapMode: Text.WrapAnywhere
            clip: true
            color: focus? "#4682b4" : "gray"
            font.pixelSize:13
            font.family: "Corbel"
            font.bold: true
            onAccepted: login_container.submit(login_container.user_name_text)
        }
    }

    //submit username button
    Rectangle{
        id:button_container
        width: parent.width * 0.15
        height: parent.height * 0.05
        color: "#4682b4"
        border.color: "white"
        border.width: 1
        anchors.top: user_name_container.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 5
        radius: 4


        MouseArea{
            id: submit_button
            anchors.fill: parent
            cursorShape: "PointingHandCursor"

            //emit submit signal. Signal handled in main.qml
            onClicked: {
                login_container.submit(login_container.user_name_text)
            }
        }

        //button label
        Text {
            id: submit_text
            text: qsTr("Sign-in")
            color: "white"
            font.pixelSize:14
            font.bold: true
            font.family: "Corbel"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
     }
}







