#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <qqml.h>
#include <QJsonArray>

using namespace std;


class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString username READ username WRITE set_username)
    Q_PROPERTY(QVariantList online_users READ online_users WRITE set_ou_list)
    Q_PROPERTY(QVariantList broadcast_conversation_list READ broadcast_conversation)


    public:
        explicit BackEnd(QObject *parent = nullptr);
        QString username();
        void set_username(const QString &new_username);
        QVariantList online_users();
        void set_ou_list(QVariantList ou_list);
        QVariantList broadcast_conversation();

        //QML BackEnd type invokable methods
        Q_INVOKABLE void add_user(QString username);
        Q_INVOKABLE void remove_user(QString username);
        Q_INVOKABLE void add_to_convo_list(QString username,QString sender, QString text_message);
        Q_INVOKABLE void remove_from_convo_list(QString username);
        Q_INVOKABLE QVariantList conversations_list(QString username);
        Q_INVOKABLE void add_to_broadcast_list(QString sender, QString text_message);

     private:
        QString my_username;
        QVariantList online_users_list;
        QVariantMap conversations;
        QVariantList broadcast_list;

};

#endif // BACKEND_H
