// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".


import socket from "./socket"

let handlebars = require("handlebars");

$(function() {
    if (!$("#likes-template").length > 0) {
        console.log("wrong-page");
        return;
    }

    let template = $($("#likes-template")[0]);
    let code = template.html();
    let tmpl = handlebars.compile(code);

    let div = $($("#post-likes")[0]);
    let path = div.data('path');
    let post_id = div.data('post_id');

    let button = $($("#like-button"));
    let user_id = button.data('user-id');

    //let buttonAdd = $($("#like-add-button"));
    //let buttonRemove = $($("#like-remove-button"));
    //let like_id = buttonRemove.data('like-id');
    let like_id = null;

    function fetch_likes() {
        console.log("fetch_likes");
        function got_likes(data) {
            console.log("got_likes");
            let html = tmpl(data);
            div.html(html);
            if (user_likes_post(data)) {
                button.off().click(remove_like);
                button.text("unlike");
            }
            else {
                button.off().click(add_like);
                button.text("like");
            }
            set_like_count(data);
        }

        $.ajax({
            url: path,
            data: {post_id: post_id},
            contentType: "application/json",
            dataType: "json",
            method: "GET",
            success: got_likes,
        });
    }


    function user_likes_post(data) {
        console.log("user_likes_post");
        let liked = false;
        data.data.forEach(function(like) {
           if (like.user_id == user_id && like.post_id == post_id) {
               liked = true;
               like_id = like.id;
               return liked;
           }
        });

        return liked;
    }
    
    function add_like() {
        console.log("add_like");

        let data = {like: {post_id: post_id, user_id: user_id}};
        $.ajax({
            url: path,
            data: JSON.stringify(data),
            contentType: "application/json",
            dataType: "json",
            method: "POST",
            success: fetch_likes,
            error: fetch_likes,
        });
    }

    function remove_like() {
        console.log("remove_like");
        let data;
        if (like_id) {
            data = {id: like_id};
        }
        else {
            console.log("no like ? ");
            return;
        }

        $.ajax({
            url: path,
            data: data,
            dataType: "json",
            method: "DELETE",
            success: fetch_likes,
            error: fetch_likes,
        });
    }

    function set_like_count(data) {
        console.log("set_like_count");
        var count = data.data.length;
        var text = " likes";
        if (count === 1) {
            text = " like";
        }

        $($("#like-count")).text(count + text);
    }

    function set_button_text(data) {
        var liked = false;
        // determine if user follows
        data.data.forEach(function(like) {
            if (user_id === like.user_id && post_id === like.post_id) {
                like_id = like.id;
                button.text("unlike");
                button.click(remove_like);
                liked = true;
                console.log(like_id)
                return;
            }
        });

        if (!liked) {
            like_id = null;
            button.text("like");
            button.click(add_like)
        }
    }

   // buttonAdd.click(add_like);
    //buttonRemove.click(remove_like);
    fetch_likes();
});