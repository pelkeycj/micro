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

// import socket from "./socket"

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

    let buttonAdd = $($("#like-add-button"));
    let buttonRemove = $($("#like-remove-button"));
    let user_id = buttonAdd.data('user-id');
    let like_id = buttonRemove.data('like-id');

    function fetch_likes() {
        function got_likes(data) {
            console.log(data);
            let html = tmpl(data);
            div.html(html);
            set_like_count(data);
            set_button_text(data);
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

    
    function add_like() {
        let data = {like: {post_id: post_id, user_id: user_id}};

        $.ajax({
            url: path,
            data: JSON.stringify(data),
            contentType: "application/json",
            dataType: "json",
            method: "POST",
            success: fetch_likes,
        });
    }

    function remove_like() {
        let data = {id: like_id};

        $.ajax({
            url: path,
            data: data,
            dataType: "json",
            method: "DELETE",
            success: fetch_likes,
        });
    }

    function set_like_count(data) {
        var count = data.data.length;
        var text = " likes";
        if (count === 1) {
            text = " like";
        }

        //get div

        console.log(count);
    }

    function set_button_text(data) {
        
    }

    buttonAdd.click(add_like);
    buttonRemove.click(remove_like);
    fetch_likes();

});
