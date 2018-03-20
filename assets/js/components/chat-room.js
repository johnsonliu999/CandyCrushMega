import React from 'react';

const ChatRoom = ({messages, userId, channel}) => {
  const msgs = messages.slice()
  msgs.reverse();
  const kinds = ["primary", "secondary", "success", "danger", "warning", "info"];

  return (
    <div className="chat-room">
      <ul>
        {msgs.map( (cur, i) =>
          <li key={i}>
            <span className={"rounded text-white bg-"+ (kinds[cur.user_id % kinds.length])}>
              User {cur.user_id}
            </span>
            <span>{cur.content}</span>
          </li>)}
      </ul>
      <input id="chatInput"/>
      <button className="btn btn-primary" onClick={
          () => {
            let chatInput = $('#chatInput');
            let content = chatInput.val().trim();
            if (content)
              channel.push("message", {user_id: userId, content: content})
            chatInput.val("");
          }
        }>
        Send
      </button>
    </div>
  );
};

export default ChatRoom;
