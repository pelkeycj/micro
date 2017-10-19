// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

$(function() {
    let user = $("meta[name=user_channel]").attr("content");
    socket.connect();

// Now that you are connected, you can join channels with a topic:
    let channel = socket.channel("updates:" + user, {});
    channel.join()
        .receive("ok", resp => { console.log("Joined successfully. Channel updates:" + user, resp) })
        .receive("error", resp => { console.log("Unable to join", resp) });

    channel.on("following_post", msg => {
       renderMsg(msg);
    });

    let postButton = $($("#new-post-btn"));
    postButton.click(createNewPost);


    function createNewPost() {
        let postTitleInput = $("#post-title");
        let postBodyInput = $("#post-body");
        let postTitle = postTitleInput.val();
        let postBody = postBodyInput.val();

        if(!isValidPost()) {
            return;
        }

        console.log(postTitle);
        console.log(postBody);

        channel.push("new_post", {user_id: user, post: {title: postTitle, body: postBody}})
            .receive("ok", post => { postSuccess(post) })
            .receive("error", reasons => { console.log("Failed to post", reasons) });
        clearInput();


        function postSuccess(msg) {
            clearInput();
            console.log("Posted", msg);
        }

        function isValidPost() {
            return postTitle.length > 0 && postBody.length > 0;
        }

        function clearInput() {
            postTitleInput.val("");
            postBodyInput.val("");
        }

    }

    // insert post as card in div
    function renderMsg(msg) {
        let card =
            $("<div class='card bg-light mx-auto mt-4'>" +
                "<div class='card-header'>" +
                    "<a href='users/" +
                    msg["user_id"] +
                    "' class='card-tag'>" +
                        "<span class='mr-3 h5 font-weight-bold'>" +
                            msg["user_name"] +
                        " </span>" +
                        "@" +
                        msg["user_handle"] +
                    "</a>" +
                "</div>" +
                "<div class='card-body'>" +
                    "<a class='card-tag h4 font-weight-bold text-center' href='users/" +
                    msg["user_id"] +
                    "/posts/" +
                    msg["post_id"] +
                    "' >" +
                        "<h4 class='text-center'>" +
                            msg["post_title"] +
                        "</h4>" +
                    "</a>" +
                    "<p class='card-text'> " +
                        msg["post_body"] +
                    "</p>" +
                "</div>" +
            "</div>");

        $("#feed-content").prepend(card)
    }
});

export default socket

