
// Blog

import stdlib.themes.bootstrap
import stdlib.web.client

type post = { string author, string title, string body, string discussion }
type comment = {string discussion, string author, string text}

exposed Network.network(post) blog = Network.cloud("blog")

exposed Network.network(comment) comments = Network.cloud("comments")

function update_sidelist(string titre, dom fenetre) {
	
	element_of_list =
	<ul>
		<li> <a onclick= { function(_) { Dom.scroll_into_view(fenetre) } }> {titre} </> </>
	</>
	;

	#sommaire =+ element_of_list;
}

function make_comment(string discussion) {

			author_ = Client.prompt("Auteur", "Commentator");
			author = (author_ ? "Commentateur");
			text_ = Client.prompt("Commentaire", "Comment");
			text = (text_ ? "Commentaire");
			commentaire = ~{discussion, author, text};

			Network.broadcast(commentaire, comments);
}


function add_comment(comment c) {

	element_of_discussion =
		<div>
			<div class="marge">
				<p class="reduit"> {c.text} </>
				<b> De {c.author} </>
			</>
		</>
	;
	#{c.discussion} =+ element_of_discussion;
}



function add_to_blog(post p) {

	element_of_blog = 
		<div class="marge"> 
			<div class="hero-unit">
				<h1> {p.title} </>
				<p class="post_body"> {p.body} </>
				<br />
				<p class="post_author a_droite"> Posté par {p.author} </>
				<br />
				<br />
				<div id=#{p.discussion} class="footer marge">
				</>
				<div class="btn btn-success a_droite" onclick = { function(_) { make_comment(p.discussion) } }> Add a comment </>
			</>
		</>
	;

	#fildublog =+ element_of_blog;
	update_sidelist(p.title, #{p.discussion});
	Dom.scroll_into_view(#{p.discussion});
}

function make_post() {
	
	author = Dom.get_value(#author_input);
	title = Dom.get_value(#title_input);
	body = Dom.get_value(#essay_input);

	discussion = Random.string(10); // FIXME security ???

	if (author == "") {
		Client.alert("Entrez l'auteur")
	}
	else {
		if (title == "") {
			Client.alert("Entrez le titre")
		}
		else {
			if (body == "") {
				Client.alert("Entrez le contenu")
			}
			else {
				post = ~{author, title, body, discussion};
				Network.broadcast(post, blog);
				Dom.clear_value(#author_input);
				Dom.clear_value(#title_input);
				Dom.clear_value(#essay_input);
			}
		}
	}
}

function start() {

	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span9">
				<u> Essai de blog en OPA </>
				<div id=#fildublog onready = { function(_) {
					Network.add_callback(add_to_blog, blog);
					Network.add_callback(add_comment, comments)
				} }> </>
			</>
			<div class="span3">
				<div class="style_input">
					<div class="decale">
						<p> Auteur
							<input id=#author_input class="input_author" />
						</>
						<p> Titre
							<input id=#title_input class="input_title" />
						</>
						<p> Message
							<textarea id=#essay_input class="input_essay" />
						</>
						</>
						<p class="publish"> 
							<div class="btn btn-info" onclick= { function(_) { make_post() } }> Publier </> 
					</>
				</>
				<div class="style_sommaire">
					<p class="titre_sommaire"> <u> Sommaire </> </>
					<div id=#sommaire />
				</>
			</>
		</>
	</>
}

Server.start(
	Server.http,
    [ {resources: @static_resource_directory("resources")} ,
    	{register: ["resources/essai3.css"]} ,
        {title: "Blog", page:start }
    ]
)