<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
<script>
$(function(){
	var $inputId = $("input[type='text']"); //아이디 입력창
	var $inputPw = $("input[type='password']"); //비밀번호 입력창
	
	$("#errorMsg").css('opacity','1');	
	if($("#corId").text() == ""){
		$(".inp.id").css('opacity','1');
		$(".id.position").css('opacity','1');
		setTimeout(function() {$inputId.focus();}, 700);
	}else{
		$(".id").css('display','none');
		$(".pw").css('display','block');
		$("#corId").css('opacity','1');
		$(".inp.pw").css('opacity','1');
		$(".pw.position").css('opacity','1');
		setTimeout(function() {$inputPw.focus();}, 700);
	}
	$("#plus").css('opacity','1');
	$("#next").css('opacity','1');
	
	$inputId.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputId.val() != ""){
				$("#next").click();	
			}else{
				$('.inp input + span').css('color','#a30404'); 
				$('.inp .border').css('background','#a30404');
				$('.inp input').css('border-bottom','2px solid #a30404');
				$("#errorMsg").text("아이디가 입력되지않았습니다");
			}	
		}
	});
	
	$inputPw.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputPw.val() != ""){
				$("#next").click();		
			}else{
				$('.inp input + span').css('color','#a30404'); 
				$('.inp .border').css('background','#a30404');
				$('.inp input').css('border-bottom','2px solid #a30404');		
				$("#errorMsg").text("비밀번호가 입력되지않았습니다");
			}	
		}
	});
	
	$("#next").bind("click", function(){
		if($("#corId").text() == ""){
			$.ajax({
				method: "post",
				data:{
					userId:$inputId.val()
				},
				success:function(result){
					var userId = $inputId.val()
					if(result){
						$(".inp.id").css('opacity','0');
						$(".id.position").css('opacity','0');
						setTimeout(function() {$(".id").css('display','none');}, 600);
						setTimeout(function() {$(".pw").css('display','block');}, 600);
						setTimeout(function() {$("#corId").css('opacity','1');}, 1000);
						setTimeout(function() {$(".inp.pw").css('opacity','1');}, 1000);
						setTimeout(function() {$(".pw.position").css('opacity','1');}, 1000);
						setTimeout(function() {$inputPw.focus();}, 1500);	
						$("#corId").css('padding','0 0');
						$("#corId").text(userId);
						$('.inp input + span').css('color','#0077FF'); 
						$('.inp .border').css('background','#0077FF');
						$('.inp input').css('border-bottom','2px solid #0077FF');
						$("#errorMsg").text("");
						
					}else{
						$('.inp input + span').css('color','#a30404'); 
						$('.inp .border').css('background','#a30404');
						$('.inp input').css('border-bottom','2px solid #a30404');
						$("#errorMsg").text("등록된 아이디가 없습니다");
					}
				},
				error:function(){
					alert("서버 오류");
				}
			});
		}else{
			$.ajax({
				method: "post",
				url:"passCheck",
				data:{
					userPw:$inputPw.val()
				},
				success:function(result){
					if(result){
						// 내용물 안보이게
						$("#corId").css('opacity','0');
						$(".inp.pw").css('opacity','0');
						$(".pw.position").css('opacity','0');
						$("#plus").css('opacity','0');
						$("#next").css('opacity','0');
						
						// 외형물 변경
						
						
						setTimeout(function() {
							$(".login").css('padding', '0rem');
							$(".demo").css('top','calc(50% - 2.5rem)');
							$(".demo").css('left','calc(50% - 2.5rem)');
							$(".demo").css('width','5rem');
							$(".demo").css('height','5rem');
							$(".icon").css('opacity','1');
						}, 600);
						
						setTimeout(function() {
							$(".demo").css('top','2%');
							$(".demo").css('left','93%');
						}, 1200);
						
						// 화면 이동//
						setTimeout(function() {window.location.href="http://localhost/note/main";}, 2000);
					}else{
						$('.inp input + span').css('color','#a30404'); 
						$('.inp .border').css('background','#a30404');
						$('.inp input').css('border-bottom','2px solid #a30404');		
						$("#errorMsg").text("올바른 비밀번호를 입력하세요");
					}
				},
				error:function(){
					alert("서버오류");
				}
			})
		}
	});
	
	// 계정만들기로 넘어가는 효과
	$("#plus").bind("click", function(){
		$("#corId").css('opacity','0');
		$(".inp").css('opacity','0');
		$("#errorMsg").css('opacity','0');
		
		setTimeout(function() {$(".position").css('opacity','0');}, 300);
		setTimeout(function() {$("#plus").css('opacity','0');}, 300);
		setTimeout(function() {$("#next").css('opacity','0');}, 300);
		setTimeout(function() {window.location.href="http://localhost/note/addUser";}, 1000);
	});
	
	
	// 아이디찾기로 넘어가는 효과
	$(".id.position").bind("click", function(){
		$("#corId").css('opacity','0');
		$(".inp").css('opacity','0');
		$("#errorMsg").css('opacity','0');
		
		setTimeout(function() {$(".position").css('opacity','0');}, 300);
		setTimeout(function() {$("#plus").css('opacity','0');}, 300);
		setTimeout(function() {$("#next").css('opacity','0');}, 300);
		setTimeout(function() {window.location.href="http://localhost/note/findId";}, 1000);
	});
		
	// 암호찾기로 넘어가는 효과
	$(".pw.position").bind("click", function(){
		$("#corId").css('opacity','0');
		$(".inp").css('opacity','0');
		$("#errorMsg").css('opacity','0');
		
		setTimeout(function() {$(".position").css('opacity','0');}, 300);
		setTimeout(function() {$("#plus").css('opacity','0');}, 300);
		setTimeout(function() {$("#next").css('opacity','0');}, 300);
		setTimeout(function() {window.location.href="http://localhost/note/findPw";}, 1000);
	});
})
</script>

<style>
@import "/note/css/user.css";

#corId{
	opacity: 0;
	transition-duration:1s;
}

.id{
	display:block;
	opacity: 0;
	transition-duration:1s;
}
.pw{
	display:none;
	opacity: 0;
	transition-duration:1s;
}
.position{
	position : absolute;
	left : 5rem;
	top : 19rem;
	transition-duration:1s;
	opacity: 0;
}
.pw.inp{
position : absolute;
	left : 5rem;
	top : 12rem;
}

#errorMsg{
	font-size: 1em;
	position : absolute;
	left : 5rem;
	top : 16rem;
	opacity: 0;
	transition-duration:1s;
}

#plus{
	position : absolute;
	left : 5rem;
	top : 23rem;
	border :none;
	background-color : transparent;
	opacity: 0;
	transition-duration:1s;
}
#next{
	position : absolute;
	left : 31rem;
	top : 23rem;
	border :none;
	background-color : transparent;
	opacity: 0;
	transition-duration:1s;
}
.icon{
	position : absolute;
	
	left : calc(50% - 2.5rem);
	top : calc(50% - 2.5rem);

	opacity: 0;
	transition-duration:1s;
	
	width: 5rem;
  	height: 5rem;
}

</style>

</head>
<body>
<% 
	String userId = (String)session.getAttribute("userId"); 
%>
<div class="cont">
	<div class="demo">
		<div class="icon">
			<img width="50" height="50" src="/note/img/friend.png">
		</div>
		<div class="login">
			<h2 id="corId">${userId}</h2>
	
			<label for="inp" class="inp id"><input type="text" name="userId" placeholder="&nbsp;" autocomplete="off"><span class="label">아이디</span><span class="border"></span></label>
			<label for="inp" class="inp pw"><input type="password" name="userPw" placeholder="&nbsp;" autocomplete="off"><span class="label">비밀번호</span><span class="border"></span></label>
			<p id="errorMsg">&nbsp;</p>
		
			<a class="id position">아이디를 잊으셨나요?</a>
			<a class="pw position">비밀번호를 잊으셨나요?</a>
	
			
			<button type="button" id="plus"><img src="img/plus.png"></button>
			<button type="button" id="next"><img src="/note/img/next.png"></button>
		</div>
	</div>
</div>
</body>
</html>