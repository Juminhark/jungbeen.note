<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="/note/js/utility.js"></script>
<script>
window.onload = function() {
	var form = document.querySelector(".form");
	var reg = form.querySelector(".reg");
	var name = form.querySelector(".name");
	var id = form.querySelector(".id");
	var pw = form.querySelector(".pw");
	var cpw = form.querySelector(".confirm-pw");
	var email = form.querySelector(".email");
	var back = form.querySelector(".back");
	var create = form.querySelector(".create");
	
	show(name);
	show(id);
	show(pw);
	show(cpw);
	show(email);
	
	create.onclick = function(e) {
		ajax({
			url:"/note/addUser",
			method:"post",
			param:[
			       {name:"userName", value:name.children[0].value},
			       {name:"userId", value:id.children[0].value},
			       {name:"userPw", value:pw.children[0].value},
			       {name:"userEmail", value:email.children[0].value}
			],
			success:function(r) {
				if(r) {
					setTimeout(function() {
						hide(name);
						hide(id);
						hide(pw);
						hide(cpw);
						hide(email);
						hide(back);
						hide(create);
						document.querySelector(".okay").style.opacity = "1";
						
						setTimeout(function() {
							ok(0);
							
							var size;
							
							if(window.innerWidth < window.innerHeight)
								size = window.innerWidth * 0.3;
							else
								size = window.innerHeight * 0.3;
							
							size = Math.round(size);
							
							setCssVar("form-height", size + "px");
							
							setTimeout(function() {
								location.href = "/note";
							}, 1000);
						}, 1000);
					}, 500);
				} else {
					hide(name);
					hide(id);
					hide(pw);
					hide(cpw);
					hide(email);
					hide(back);
					hide(create);
					document.querySelector(".nope").style.opacity = "1";
					
					setTimeout(function() {
						no(0);
						
						var size;
						
						if(window.innerWidth < window.innerHeight)
							size = window.innerWidth * 0.3;
						else
							size = window.innerHeight * 0.3;
						
						size = Math.round(size);
						
						setCssVar("form-height", size + "px");
						
						setTimeout(function() {
							location.href = "/note";
						}, 1000);
					}, 500);
				}
			}
		});
	}
	console.log("asd");
	back.onclick = function(e) {
		hide(name);
		hide(id);
		hide(pw);
		hide(cpw);
		hide(email);
		hide(back);
		
		setTimeout(function() {
			create.style.top = "calc(60% - var(--form-width) * 0.2 / 2)";
			create.style.left = "calc(50% - var(--form-width) * 0.5 / 2)";
			
			var size;
			
			if(window.innerWidth < window.innerHeight)
				size = window.innerWidth * 0.3;
			else
				size = window.innerHeight * 0.3;
			
			size = Math.round(size);
			
			setCssVar("form-height", size + "px");
			setTimeout(function() {
				location.href = "/note";			
			}, 250);
		}, 250);
	}
	
	name.children[0].focus();
	
	name.children[0].onkeydown = function(e) {
		if(e.keyCode == 13)
			if(this.value.length > 0) {
				on(1);
				ok(1);
				id.children[0].focus();
			} else {
				ko(1);
				no(1);
			}
	}
	
	id.children[0].onkeydown = function(e) {
		if(e.keyCode == 13) {
			var id = this.value;
			ajax({
				url:"/note/idCheck",
				method:"post",
				param:[{name:"userId", value:id}],
				success:function(response) {
					if(response) {
						on(2);
						ok(2);
						pw.children[0].focus();
					} else {
						ko(2);
						no(2);
					}
				}
			});
		}
	}
	
	pw.children[0].onkeydown = function(e) {
		if(e.keyCode == 13)
			if(this.value.length > 8) {
				ok(3);
				on(3);
				cpw.children[0].focus();
			} else {
				ko(3);
				no(3);
			}
	}
	
	cpw.children[0].onkeydown = function(e) {
		if(e.keyCode == 13)
			if( this.value == pw.children[0].value) {
				on(4);
				ok(4);
				email.children[0].focus();
			} else {
				ko(4);
				no(4);
			}
	}
	
	email.children[0].onkeydown = function(e) {
		if(e.keyCode == 13) {
			if(this.value.length > 0) {
				ok(5);
				on(5);
				
				triggerEvent(create, "click");
			} else {
				ko(5);
				no(5);
			}
		}
	}
	
	function getCssVar(variable) {
		return document.querySelector(":root").style.getPropertyValue("--" + variable);
	}

	function setCssVar(name, value) {
		document.querySelector(":root").style.setProperty("--" + name, value);
	}
	
	function hide(el) {
		el.style.opacity = "0";
		setTimeout(function() {
			el.style.display = "none";
		}, 500);
	}
	
	function show(el) {
		el.style.display = "block";
		el.style.opacity = "1";
	}
	
	var okay = document.querySelectorAll(".okay");
	var okayLeft = document.querySelectorAll(".okay-left");
	var okayRight = document.querySelectorAll(".okay-right");
	
	for(var i = 0; i < okay.length; i++)
		ko(i);
	
	function ko(idx) {
		okayRight[idx].style.height = "0px";
		okayRight[idx].style.top = "80%";
		
		setTimeout(function() {
			okayLeft[idx].style.height = "0px";
			okayLeft[idx].style.left = "7.5%";
		}, 200);		
	}
	
	function ok(idx) {
		okayLeft[idx].style.height = "calc(var(--okay-size) / 6 * 2)";
		okayLeft[idx].style.left = "calc(var(--okay-size) / 6 * 2)";
		
		setTimeout(function() {
			okayRight[idx].style.height = "calc(var(--okay-size) / 6 * 5)";
			okayRight[idx].style.top = "calc(var(--okay-size) / 4 * 3.25 - var(--okay-size)  / 6 * 5)";
		}, 150);
	}
	
	var nope = document.querySelectorAll(".nope");
	var nopeLeft = document.querySelectorAll(".nope-left");
	var nopeRight = document.querySelectorAll(".nope-right");
	
	for(var i = 0; i < nope.length; i++)
		on(i);
	
	function on(idx) {
		nopeLeft[idx].style.transform = "rotate(-45deg)";
		
		setTimeout(function() {
			nopeLeft[idx].style.height = "0px";
			nopeLeft[idx].style.left = "10%";
			nopeLeft[idx].style.top = "10%";
			
			nopeRight[idx].style.height = "0px";
			nopeRight[idx].style.left = "10%";
			nopeRight[idx].style.top = "10%";
		}, 50);
	}
	
	function no(idx) {
		nopeLeft[idx].style.height = "var(--nope-size)";
		nopeLeft[idx].style.left = "calc(var(--nope-size) / 2 - var(--nope-size) / 12 / 2)";
		nopeLeft[idx].style.top = "0px";
		
		nopeRight[idx].style.height = "var(--nope-size)";
		nopeRight[idx].style.left = "calc(var(--nope-size) / 2 - var(--nope-size) / 12 / 2)";
		nopeRight[idx].style.top = "0px";
		
		setTimeout(function() {
			nopeLeft[idx].style.transform = "rotate(45deg)";
		}, 50);
	}

	
	function resizeForm(ratio) {
		var size;
		
		if(window.innerWidth < window.innerHeight)
			size = window.innerWidth * ratio;
		else
			size = window.innerHeight * ratio;
		
		size = Math.round(size);
		
		setCssVar("form-width", size + "px");
	}
	
	resizeForm(0.3);
	
	window.onresize = function(e) {
		resizeForm(0.3);
	}
}
</script>
<style>
:root {
	--form-width:300px;
	--form-height:calc(var(--form-width) / 3 * 4);
	--okay-size:20px;
	--nope-size:20px;
}
.form {
	position:fixed;
	
	width:var(--form-width);
	height:var(--form-height);
	
	left:calc(50% - var(--form-width) / 2);
	top:calc(50% - var(--form-height) / 2);
	
	border-radius:calc(var(--form-width) * 0.05);
	
	background-color:LightGray;

	box-shadow:0px 0px 10px 1px rgba(0, 0, 0, 0.5);
	
	opacity:1; 
	transition-duration:0.25s;
}
.form>* {
	opacity:0;
	
	position:absolute;
	
	width:calc(var(--form-width) * 0.5);
	height:calc(var(--form-width) * 0.2);
	
	left:calc(50% - var(--form-width) * 0.5 / 2);

	text-align:center;
	
	transition-duration:0.25s;
}
.form .name {
	top:calc(20% - var(--form-width) * 0.2 / 2);
}
.form .id {
	top:calc(35% - var(--form-width) * 0.2 / 2);
}
.form .pw {
	top:calc(50% - var(--form-width) * 0.2 / 2);
}
.form .confirm-pw {
	top:calc(65% - var(--form-width) * 0.2 / 2);
}
.form .email {
	top:calc(80% - var(--form-width) * 0.2 / 2);
}
.form .back {
	opacity:1;

	left:calc(15% - var(--form-width) * 0.5 / 2);
	top:calc(92.5% - var(--form-width) * 0.2 / 2);
}
.form .create {
	opacity:1;

	left:calc(80% - var(--form-width) * 0.5 / 2);
	top:calc(92.5% - var(--form-width) * 0.2 / 2);
}
.form span {
	position:absolute;
	
	width:100%;
	height:1em;
	
	left:0px;
	top:calc(50% - 0.5em);
	
	text-align:center;
	font-size:calc(var(--form-width) * 0.075);
	color:gray;
	
	transition-duration:0.25s;
}
.form input {
	position:absolute;
	
	width:100%;
	height:100%;
	
	left:0px;
	top:0px;
	
	border:0px;
	outline:0px;
	margin:0px;
	padding:0px;
	
	text-align:center;
	font-size:calc(var(--form-width) * 0.075);
	color:gray;
	
	background-color:transparent;
	
	transition-duration:0.25s;
}
.okay {
	position:absolute;
	
	width:var(--okay-size);
	height:var(--okay-size);

	left:110%;
	top:30%;
}
.okay .okay-left {
	position:absolute;
	
	width:calc(var(--okay-size) / 12);
	height:calc(var(--okay-size) / 6 * 2);
	
	left:calc(var(--okay-size) / 6 * 2);
	top:calc(var(--okay-size) / 4 * 3.25 - var(--okay-size) / 6 * 2);
	
	border-radius:calc(var(--okay-size) / 12 / 2);
	
	transform-origin:left bottom;
	transform:rotate(-45deg);
	
	background-color:green;
	
	transition-duration:0.25s;
}
.okay .okay-right {
	position:absolute;
	
	width:calc(var(--okay-size) / 12);
	height:calc(var(--okay-size) / 6 * 5);
	
	left:calc(var(--okay-size) / 6 * 2 - var(--okay-size) / 12);
	top:calc(var(--okay-size) / 4 * 3.25 - var(--okay-size)  / 6 * 5);
	
	border-radius:calc(var(--okay-size) / 12 / 2);
	
	transform-origin:right bottom;
	transform:rotate(45deg);
	
	background-color:green;
	
	transition-duration:0.25s;
}

.nope {
	position:absolute;
	
	width:var(--nope-size);
	height:var(--nope-size);
	
	left:110%;
	top:30%;
}
.nope .nope-left {
	position:absolute;
	
	width:calc(var(--nope-size) / 12);
	height:var(--nope-size);
	
	left:calc(var(--nope-size) / 2 - var(--nope-size) / 12 / 2);
	top:0px;
	
	border-radius:calc(var(--nope-size) / 12 / 2);
	
	background-color:red;
	
	transform:rotate(45deg);
	
	transition-duration:0.25s;
}
.nope .nope-right {
	position:absolute;
	
	width:calc(var(--nope-size) / 12);
	height:var(--nope-size);
	
	left:calc(var(--nope-size) / 2 - var(--nope-size) / 12 / 2);
	top:0px;
	
	border-radius:calc(var(--nope-size) / 12 / 2);
	
	background-color:red;
	
	transform:rotate(-45deg);
	
	transition-duration:0.25s;
}


body {
	background-color:gray;
}
</style>
</head>
<body>

<div class="form">
	<div class="okay" style="--okay-size:100px; left:calc(50% - 50px); top:calc(50% - 50px)">
		<div class="okay-left"></div>
		<div class="okay-right"></div>
	</div>
	
	<div class="nope" style="--nope-size:100px; left:calc(50% - 50px); top:calc(50% - 50px)">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>

	<div class="name">
		<input type="text" placeholder="Name">
		<div class="okay">
			<div class="okay-left"></div>
			<div class="okay-right"></div>
		</div>
		
		<div class="nope">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>
	</div>
	
	<div class="id">
		<input type="text" placeholder="ID">
		<div class="okay">
			<div class="okay-left"></div>
			<div class="okay-right"></div>
		</div>
		
		<div class="nope">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>
		
	</div>
	
	<div class="pw">
		<input type="password" placeholder="Password">
		<div class="okay">
			<div class="okay-left"></div>
			<div class="okay-right"></div>
		</div>
		
		<div class="nope">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>
	</div>
	
	<div class="confirm-pw">
		<input type="password" placeholder="Password">
		<div class="okay">
			<div class="okay-left"></div>
			<div class="okay-right"></div>
		</div>
		
		<div class="nope">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>
	</div>
	<div class="email">
		<input type="email" placeholder="Email">
		<div class="okay">
			<div class="okay-left"></div>
			<div class="okay-right"></div>
		</div>
		
		<div class="nope">
			<div class="nope-left"></div>
			<div class="nope-right"></div>
		</div>
	</div>
	
	<div class="back"><span>&lt; Back</span></div>
	<div class="create"><span>Create &gt;</span></div>
</div>

</body>
</html>