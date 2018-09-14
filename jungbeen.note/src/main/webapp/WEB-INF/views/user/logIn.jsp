<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="/note/js/utility.js"></script>
<script>
window.onload = function() {
	var lock = document.querySelectorAll(".lock");
	var head = document.querySelectorAll(".head");
	var body = document.querySelectorAll(".body");
	
	function unlock(idx) {
		head[idx].setAttribute("class", "head press");
		setTimeout(function() {
			head[idx].setAttribute("class", "head lift");
			lock[idx].style.setProperty("--lock-color", "MediumSeaGreen");
			setTimeout(function() {
				head[idx].setAttribute("class", "head lift open");
			}, 250);
		}, 250);
	}
	
	function locked(idx) {
		head[idx].setAttribute("class", "head close");
		setTimeout(function() {
			head[idx].setAttribute("class", "head press");
			setTimeout(function() {
				head[idx].setAttribute("class", "head");
				lock[idx].style.setProperty("--lock-color", "Tomato");
			}, 250);
		}, 250);
	}
	
	function toggle(idx) {
		if(head[idx].classList.contains("open"))
			locked(idx);
		else
			unlock(idx);
	}
	
	function shake(idx) {
		lock[idx].style.transform = "rotate(10deg)";
		
		setTimeout(function() {
			lock[idx].style.transform = "rotate(-10deg)";
			
			setTimeout(function() {
				lock[idx].style.transform = "rotate(0deg)";
			}, 250);
		}, 250);
	}
	
	function getCssVar(variable) {
		return document.querySelector(":root").style.getPropertyValue("--" + variable);
	}

	function setCssVar(name, value) {
		document.querySelector(":root").style.setProperty("--" + name, value);
	}
	
	/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
	
	var form = document.querySelector(".form");
	var id = form.querySelector(".id");
	var pw = form.querySelector(".pw");
	var reg = form.querySelector(".reg");
	var find = form.querySelector(".find");
	
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
	
	show(lock[0]);
	show(lock[1]);
	show(id);
	show(pw);
	show(reg);
	show(find);
	
	id.children[0].onkeydown = function(e) {
		if(e.keyCode == 13) {
			var id = this.value;
			ajax({
				url:"/note/",
				method:"post",
				param:[{name:"userId", value:id}],
				success:function(response) {
					if(response) {
						console.log(response);
						unlock(0);
						
						setTimeout(function() {
							pw.children[0].focus();
						}, 500);
					} else
						shake(0);
				}
			});
		}
	}
	
	pw.children[0].onkeydown = function(e) {
		if(e.keyCode == 13) {
			var pw = this.value;
			
			ajax({
				url:"/note/passCheck",
				method:"post",
				param:[{name:"userPw", value:pw}],
				success:function(response) {
					if(response) {
						console.log(response);
						unlock(1);
						
						setTimeout(function() {
							document.querySelector("input[type='submit']").click();
						}, 1000);
					} else
						shake(1);
				}
			});
		}
	}
	
	reg.onclick = function(e) {
		hide(lock[0]);
		hide(lock[1]);
		hide(id);
		hide(pw);
		hide(find);
		
		setTimeout(function() {
			reg.style.top = "calc(92.5% - var(--form-width) * 0.2 / 2)";
			reg.style.left = "calc(80% - var(--form-width) * 0.5 / 2)";
			
			var size;
			
			if(window.innerWidth < window.innerHeight)
				size = window.innerWidth * 0.3;
			else
				size = window.innerHeight * 0.3;
			
			size = Math.round(size);
			
			setCssVar("form-height", size / 4 * 5 + "px");	
			
			setTimeout(function() {
				location.href = "/note/addUser";				
			}, 250);
		}, 250);
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
	--form-height:var(--form-width);

	--lock-size:calc(var(--form-width) / 20);
	--lock-color:Tomato;
}
.lock {
	position:absolute;
	
	width:calc(var(--lock-size) * 1.25);
	height:var(--lock-size);
	
	left:75%;
	
	z-index:10;
	
	transition-duration:0.25s;
}
.lock .head {
	position:absolute;
	
	width:calc(var(--lock-size) * 0.7);
	height:calc(var(--lock-size) * 0.5);
	
	left:calc(var(--lock-size) * 0.25 / 2);
	top:calc(var(--lock-size) * -0.75);
	
	border:calc(var(--lock-size) * 0.15) solid var(--lock-color);
	border-radius:calc(var(--lock-size) * 0.25) calc(var(--lock-size) * 0.25) 0px 0px;
	border-color:var(--lock-color) var(--lock-color) transparent var(--lock-color);
	
	transition-duration:0.25s;
}
.lock .head .square {
	position:absolute;
	
	width:calc(var(--lock-size) * 0.15);
	
	background-color:var(--lock-color);
}
.lock .head .square:first-child {
	height:calc(var(--lock-size) * 0.5);

	left:calc(var(--lock-size) * -0.15);
	top:calc(var(--lock-size) * 0.5);
}
.lock .head .square:last-child {
	height:calc(var(--lock-size) * 0.15);
	
	left:calc(var(--lock-size) * 0.7);
	top:calc(var(--lock-size) * 0.5);
}
.lock .body {
	position:absolute;

	width:calc(var(--lock-size) * 1.25);
	height:var(--lock-size);
	
	left:0px;
	top:0px;
	
	border-radius:calc(var(--lock-size) * 0.15);
	
	background-color:var(--lock-color);
}
.lock .lift {
	top:calc(var(--lock-size) * -1);
}
.lock .press {
	top:calc(var(--lock-size) * -0.5);
}
.lock .open {
	left:calc(var(--lock-size) * -0.7);
	transform:rotateY(180deg);
}
.lock .close {
	top:calc(var(--lock-size) * -1);
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
.form>* {opacity:0;}
.form .id {
	position:absolute;
	
	width:calc(var(--form-width) * 0.5);
	height:calc(var(--form-width) * 0.2);
	
	left:calc(50% - var(--form-width) * 0.5 / 2);
	top:calc(20% - var(--form-width) * 0.2 / 2);
	
	transition-duration:0.25s;
}
.form .pw {
	position:absolute;
	
	width:calc(var(--form-width) * 0.5);
	height:calc(var(--form-width) * 0.2);
	
	left:calc(50% - var(--form-width) * 0.5 / 2);
	top:calc(40% - var(--form-width) * 0.2 / 2);
	
	transition-duration:0.25s;
}
.form .reg {
	position:absolute;
	opacity:1;
	
	width:calc(var(--form-width) * 0.5);
	height:calc(var(--form-width) * 0.2);
	
	left:calc(50% - var(--form-width) * 0.5 / 2);
	top:calc(60% - var(--form-width) * 0.2 / 2);
	
	text-align:center;
	
	transition-duration:0.25s;
}
.form .find {
	position:absolute;
	
	width:calc(var(--form-width) * 0.5);
	height:calc(var(--form-width) * 0.2);
	
	left:calc(50% - var(--form-width) * 0.5 / 2);
	top:calc(80% - var(--form-width) * 0.2 / 2);
	
	text-align:center;
	
	transition-duration:0.25s;
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

body {
	background-color:gray;
}

form {
	display:none;
}
</style>
</head>
<body>

<form method="post" action="/note/main">
	<input type="submit"/>
</form>

<div class="form">
	<div class="lock" style="top:20%;">
		<div class="head">
			<div class="square"></div>
			<div class="square"></div>
		</div>
		<div class="body">
		</div>
	</div>
	
	<div class="lock" style="top:40%;">
		<div class="head">
			<div class="square"></div>
			<div class="square"></div>
		</div>
		<div class="body">
		</div>
	</div>
	<div class="id">
		<input autofocus type="text" placeholder="ID"/>
	</div>
	<div class="pw">
		<input type="password" placeholder="Password">
	</div>
	<div class="reg"><span>Create</span></div>
	<div class="find"><span>Find</span></div>
</div>

</body>
</html>