import React from 'react';

const ChatRoom = ({messages, userId, channel}) => {
  const msgs = messages.slice()
  msgs.reverse();
  const kinds = ["primary", "secondary", "success", "danger", "warning", "info"];

  return (
    <div className="chat-room">
      <div className="m-1 chat-input input-group">
        <input id="chatInput" className="form-control"/>
        <div className="input-group-append">
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
      </div>
      <div className="messages">
        {msgs.map( (cur, i) =>
          <p key={i}>
            <span className={"p-1 m-2 rounded text-white bg-"+ (kinds[cur.user_id % kinds.length])}>
              User {cur.user_id}
            </span>
            <span>{cur.content}</span>
          </p>)}
      </div>
    </div>
  );
};

export default ChatRoom;
