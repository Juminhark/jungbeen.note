<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jungbeen.note.user.domain.User" %>
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
	var $inputName = $("input[type='text']"); //이름 입력창
	var $inputEmail = $("input[type='email']"); //이메일 입력창
	
	// 암호찾기 창 활성화
	$("#name").css('opacity','1');
	$("#errorMsg").css('opacity','1');
	$("#back").css('opacity','1');
	$("#next").css('opacity','1');
	setTimeout(function() {$inputName.focus();}, 700);
	
	// 이름입력창에 enter를 누르면 이벤트 작용
	// 입력된 값이 있으면 next 버튼 클릭하고 email입력창으로 이동, 입력된 값이 없으면 에러상태
	$inputName.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputName.val() != ""){
				$("#next").click();			
			}else{
				$('#name input:focus + span').css('color','#a30404'); 
				$('#name .border').css('background','#a30404');
				$('#name input').css('border-bottom','2px solid #a30404');
				$("#errorMsg").text("이름이 입력되지않았습니다");
			}	
		}
	});
	
	// 이메일입력창에 enter를 누르면 이벤트 작용
	// 입력된 값이 있으면 next 버튼 클릭하고, 입력된 값이 없으면 에러상태
	$inputEmail.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputEmail.val() != ""){
				$("#next").click();	
			}else{
				$('#email input:focus + span').css('color','#a30404'); 
				$('#email .border').css('background','#a30404');
				$('#email input').css('border-bottom','2px solid #a30404');		
				$("#errorMsg").text("이메일이 입력되지않았습니다");
			}	
		}
	});
	
	// next 버튼을 눌렀을때 이벤트 작용
	$("#next").bind("click", function(){
		// 이름입력창에 활성화 되었을때 버튼이 클릭되면 이름값을 전송하여 해당 이름이 있는지 찾는다.
		if($("#name").css('display') == "block"){
			$.ajax({
				method: "post",
				data:{
					userName:$inputName.val()
				},
				success:function(result){
					var userName = $inputName.val();
					if(result){
						$("#corName").text(userName);
						$("#name").css('opacity','0');			
						$("#errorMsg").css('opacity','0');
						setTimeout(function() {$("#errorMsg").text("해당 이름으로 등록된 이메일을 입력하세요");}, 500);
						setTimeout(function() {$("#corName").css('opacity','1');}, 500);
						setTimeout(function() {$("#name").css('display','none');}, 500);
						setTimeout(function() {$("#email").css('display','block');}, 500);
						setTimeout(function() {$("#email").css('opacity','1');}, 500);
						setTimeout(function() {$("#errorMsg").css('opacity','1');}, 500);
						
						$('.inp input:focus + span').css('color','#0077FF'); 
						$('.inp .border').css('background','#0077FF');
						$('.inp input').css('border-bottom','2px solid #0077FF');
						
					}else{
						$('.inp input:focus + span').css('color','#a30404'); 
						$('.inp .border').css('background','#a30404');
						$('.inp input').css('border-bottom','2px solid #a30404');
						$("#errorMsg").text("등록된 이름이 없습니다");
					}
				},
				error:function(){
					alert("서버 오류");
				}
			});
		
		}else if(($("#name").css('display') == "none")&&($("#email").css('display') == "none")){
			window.location.href="http://localhost/note/intoPw";
		// 이메일창이 활성화되어있을때 찾은 이름이 가지고있는 이메일을 비교하여 2개의 정보가 일치하는 이메일로 이메일을 전송한다.
		}else{
			var userEmail = $inputEmail.val();
			$("#corEmail").text(userEmail);	
			$("#corName").css('opacity','0');
			$("#email").css('opacity','0');
			$("#Msg").css('display','block');
			$("#errorMsg").css('opacity','0');
			$.ajax({
				method: "post",
				url:"emailSend",
				data:{
					userEmail:$inputEmail.val()
				},
				success:function(result){
					if(result){
						setTimeout(function() {$("#Msg").css('opacity','1');}, 500);
						setTimeout(function() {$("#email").css('display','none');}, 500);
					}else{
						setTimeout(function() {$("#corName").css('opacity','1');}, 500);
						setTimeout(function() {$("#email").css('opacity','1');}, 500);
						setTimeout(function() {$("#errorMsg").css('opacity','1');}, 500);
						
						setTimeout(function() {$('.inp input:focus + span').css('color','#a30404'); }, 500);
						setTimeout(function() {$('.inp .border').css('background','#a30404');}, 500);
						setTimeout(function() {$('.inp input').css('border-bottom','2px solid #a30404');}, 500);	
						setTimeout(function() {$("#errorMsg").text("등록된 이메일이 아닙니다.");}, 500); 
					}		
				},
				error:function(){
					alert("서버오류");
				}
			});
		}
		
	});	
	
	// back : 로그인으로 이동
	$("#back").bind("click", function(){	
		if($("#corName").css('opacity') == 0){
			$("#name").css('opacity','0');
			$("#Msg").css('opacity','0');
			$("#errorMsg").css('opacity','0');
			$("#back").css('opacity','0');
			$("#next").css('opacity','0');
			setTimeout(function() {window.location.href="http://localhost/note/logout";}, 700);	
		}else{
			$("#corName").css('opacity','0');
			$("#email").css('opacity','0');
			$("#errorMsg").css('opacity','0');
			$("#back").css('opacity','0');
			s$("#next").css('opacity','0');
			setTimeout(function() {window.location.href="http://localhost/note/logout";}, 700);	
		}
	});
})

$(document).ajaxStart(function() {
	$("#progress").css('opacity','1');
}).ajaxSuccess(function() {
	$("#progress").css('opacity','0');
});

</script>

<style>
@import "/note/css/user.css";

.inp{
	position : absolute;
	left : 5rem;
	top : 12rem;
	opacity: 0;
	transition-duration:1s;
}
#name{display: block;}
#email{display: none;}

#corName{
	opacity: 0;
	transition-duration:1s;
}
#errorMsg{
	opacity: 0;
	font-size: 1em;
	position : absolute;
	left : 5rem;
	top : 18rem;
	transition-duration:1s;
}

#Msg{
	display: none;
	position : absolute;
	left : 6rem;
	top : 7rem;
	opacity: 0;
	transition-duration:1s;
}

#back{
	position : absolute;
	left : 5rem;
	top : 23rem;
	border :none;
	opacity: 0;
	background-color : transparent;
	transition-duration:1s;
}
#next{
	position : absolute;
	left : 31rem;
	top : 23rem;
	border :none;
	opacity: 0;
	background-color : transparent;
	transition-duration:1s;
}

#progress{
	position : absolute;
	left :	17rem;
	top : 17rem;
	opacity: 0;
	transition-duration:1s;
}
</style>

</head>
<body>
<div class="cont">
	<div class="demo">
		<div class="login">
			<h2 id="corName"></h2>
			
			<div id="progress"><img src="img/loading.gif"></div>
		
			<h3 id="Msg"><span id="corEmail"></span>으로<br> 암호가 전송되었습니다.</h3>
			<label for="inp" class="inp" id="name"><input type="text" name="userName" placeholder="&nbsp;" autocomplete="off"><span class="label">이름</span><span class="border"></span></label>
			<label for="inp" class="inp" id="email"><input type="email" name="userEmail" placeholder="&nbsp;" autocomplete="off"><span class="label">이메일</span><span class="border"></span></label>
			<p id="errorMsg">해당 아이디에 맞는 이름을 입력해주세요</p>
			<button type="button" id="back"><img src="img/back.png"></button>
			<button type="button" id="next"><img src="img/next.png"></button>
		</div>
	</div>
</div>

</body>
</html>