import UIKit
import MessageKit

class TalkViewController: MessagesViewController {

    var messageList: [MockMessage] = []

       lazy var formatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
        
           return formatter
       }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            self.messageList = self.getMessages()
          // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
         self.messagesCollectionView.scrollToBottom()
        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray

//         メッセージ入力時に一番下までスクロール
//         scrollsToBottomOnKeybordBeginsEditing = true // default false
//         maintainPositionOnKeyboardFrameChanged = true // default false
    }


    // サンプル用に適当なメッセージ
    func getMessages() -> [MockMessage] {
        return [
            createMessage(text: "めっちゃいい曲だね！"),
            createMessage(text: "そう！最近、髭男officialハマってるの〜"),
            createMessage(text: "宿命とかもいいよ〜"),
            createMessage(text: "ライブ行きたいな〜"),
            createMessage(text: "一緒に行く？"),
            createMessage(text: "え！いこいこ！"),
            createMessage(text: "じゃあ明日10時にイオン集合ね！"),
            createMessage(text: "おっけー楽しみにしとくね！"),
            createMessage(text: "うほ"),
            createMessage(text: "うほうほ"),
            createMessage(text: "うほうほうほ"),
            createMessage(text: "うほうほうほうほ"),
            createMessage(text: "おなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーーおなかすいたなーーーーーーー"),
        ]
    }


     func createMessage(text: String) -> MockMessage {
            let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                               .foregroundColor: UIColor.black])
            return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
}

extension TalkViewController: MessagesDataSource{

    func currentSender() -> SenderType {
        return Sender(id: "123", displayName: "自分")
    }

    func otherSender() -> Sender {
        return Sender(id: "456", displayName: "相手名")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }


}



// メッセージのdelegate
extension TalkViewController: MessagesDisplayDelegate {

    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    // メッセージの背景色を変更している（自分：紫、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 176/255, green: 97/255, blue: 253/255, alpha: 1) :   //自分
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)    //相手
    }



    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {


       let avatar: Avatar
       let image = UIImage(named: "profile5")
       avatar = Avatar(image: image)
       avatarView.set(avatar: avatar)

    }

}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension TalkViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 8
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 4
    }
}

extension TalkViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension TalkViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {

                let imageMessage = MockMessage(image: image, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])

            } else if let text = component as? String {

                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                   .foregroundColor: UIColor.white])
                let message = MockMessage(attributedText: attributedText, sender: currentSender() as! Sender, messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
