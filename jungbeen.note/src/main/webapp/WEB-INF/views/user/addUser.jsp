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
	var $inputName = $("input[name='userName']"); //이름 입력창
	var $inputId = $("input[name='userId']");     //아이디 입력창
	var $inputPw = $("input[name='userPw']");     //비밀번호 입력창
	var $checkPw = $("input[name='checkPw']");    //비밀번호 확인 입력창
	var $inputEmail = $("input[name='userEmail']");    //이메일 입력창
	
	//계정만들기 오픈 효과	
	$(".demo").css('height','53rem');
	$("#back").css('top','47rem');
	$("#next").css('top','47rem');
	
	setTimeout(function() {$("#nameCheck").css('opacity','1');}, 500);
	setTimeout(function() {$("#idCheck").css('opacity','1');}, 500);
	setTimeout(function() {$("#pw").css('opacity','1');}, 500);
	setTimeout(function() {$("#pwCheck").css('opacity','1');}, 500);
	setTimeout(function() {$("#email").css('opacity','1');}, 500);
	setTimeout(function() {$("#back").css('opacity','1');}, 500);
	setTimeout(function() {$("#next").css('opacity','1');}, 500);
	setTimeout(function() {$inputName.focus();}, 1200);
	
	// 이름 입력창에서 enter를 눌렀을 때 값이 있으면 아이디 입력창으로 이동. 
	$inputName.bind("keydown", function(event){
		if(event.which == 13){
			if($inputName.val() != ""){
				$('#nameCheck input + span').css('color','#0077FF'); 
				$('#nameCheck .border').css('background','#0077FF');
				$('#nameCheck input').css('border-bottom','2px solid #0077FF');	
				$("#nameError").text("이름 확인 완료");
				$inputId.focus();
			}else{
				$('#nameCheck input + span').css('color','#a30404');
				$('#nameCheck .border').css('background','#a30404');
				$('#nameCheck input').css('border-bottom','2px solid #a30404');
				$("#nameError").text("이름이입력되지않았습니다");
			}		
		}
	});
	
	// tab키로 넘어갈때를 입력값이 있으면 확인
	$inputName.focusout(function(){
		if($inputName.val() != ""){
			$('#nameCheck input + span').css('color','#0077FF'); 
			$('#nameCheck .border').css('background','#0077FF');
			$('#nameCheck input').css('border-bottom','2px solid #0077FF');	
			$("#nameError").text("이름 확인 완료");
			$inputId.focus();
		}
	});
	
	// 아이디 입력창에서 enter를 눌렀을때 값이 있으면 중복 확인 후 
	$inputId.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputId.val() != ""){
				$.ajax({
					method: "post",
					url:"idCheck",
					data:{
						userId:$inputId.val()
					},
					success:function(result){
						if(result){
							$('#idCheck input + span').css('color','#0077FF'); 
							$('#idCheck .border').css('background','#0077FF');
							$('#idCheck input').css('border-bottom','2px solid #0077FF');	
							$("#idError").text("사용 가능한 아이디입니다");
							$inputPw.focus();
						}else{
							$('#idCheck input + span').css('color','#a30404'); 
							$('#idCheck .border').css('background','#a30404');
							$('#idCheck input').css('border-bottom','2px solid #a30404');		
							$("#idError").text("이미 있는 아이디입니다");
						}
					},
					error:function(){
						alert("서버오류.")
					}
				})
			}else{
				$('#idCheck input + span').css('color','#a30404'); 
				$('#idCheck .border').css('background','#a30404');
				$('#idCheck input').css('border-bottom','2px solid #a30404');
				$("#idError").text("아이디가 입력되지않았습니다");
			}

		}
	});
	
	// tab키로 넘어갈때를 입력값이 있으면 확인
	$inputId.focusout(function(){
		if($inputId.val() != ""){
			$.ajax({
				method: "post",
				url:"idCheck",
				data:{
					userId:$inputId.val()
				},
				success:function(result){
					if(result){
						$('#idCheck input + span').css('color','#0077FF'); 
						$('#idCheck .border').css('background','#0077FF');
						$('#idCheck input').css('border-bottom','2px solid #0077FF');	
						$("#idError").text("사용 가능한 아이디입니다");
						$inputPw.focus();
					}else{
						$('#idCheck input + span').css('color','#a30404'); 
						$('#idCheck .border').css('background','#a30404');
						$('#idCheck input').css('border-bottom','2px solid #a30404');		
						$("#idError").text("이미 있는 아이디입니다");
					}
				},
				error:function(){
					alert("서버오류.")
				}
			})
		}
	});
	
	// 비밀번호 입력창에서 enter누를때 
	$inputPw.bind("keydown", function(event) {
		if(event.which == 13) {
			if($inputPw.val() != ""){
				$('#pw input + span').css('color','#0077FF'); 
				$('#pw .border').css('background','#0077FF');
				$('#pw input').css('border-bottom','2px solid #0077FF');	
				$("#pwError").text("암호 입력 완료");
				$checkPw.focus();
			}else{
				$('#pw input + span').css('color','#a30404');  
				$('#pw .border').css('background','#a30404');  
				$('#pw input').css('border-bottom','2px solid #a30404'); 
				$("#pwError").text("암호가 입력되지않았습니다");
			}	
		}
	});
	
	// tab키로 넘어갈때를 입력값이 있으면 확인
	$inputPw.focusout(function(){
		if($inputPw.val() != ""){
			$('#pw input + span').css('color','#0077FF'); 
			$('#pw .border').css('background','#0077FF');
			$('#pw input').css('border-bottom','2px solid #0077FF');	
			$("#pwError").text("암호 입력 완료");
			$checkPw.focus();
		}
	});
	
	//'비밀번호'와 '비밀번호 확인'을 비교.
	$checkPw.bind("keydown", function(event) {
		if(event.which == 13) {
			if( $checkPw.val() != ""){
				var input = $("input[name='userPw']").val();
				var check = $("input[name='checkPw']").val();
				if(input == check){	
					$('#pwCheck input + span').css('color','#0077FF'); 
					$('#pwCheck .border').css('background','#0077FF');
					$('#pwCheck input').css('border-bottom','2px solid #0077FF');
					$("#pwckError").text("비밀번호 확인 완료");
					$inputEmail.focus();
				}else{
					$('#pwCheck input + span').css('color','#a30404'); 
					$('#pwCheck .border').css('background','#a30404');
					$('#pwCheck input').css('border-bottom','2px solid #a30404');		
					$("#pwckError").text("비밀번호가 틀렸습니다");
				}
			}else{
				$('#pwCheck input + span').css('color','#a30404'); 
				$('#pwCheck .border').css('background','#a30404');
				$('#pwCheck input').css('border-bottom','2px solid #a30404');		
				$("#pwckError").text("비밀번호 확인이 입력되지않았습니다");
			}		
		}
	});
	
	// tab키로 넘어갈때를 입력값이 있으면 확인
	$checkPw.focusout(function(){
		if( $checkPw.val() != ""){
			var input = $("input[name='userPw']").val();
			var check = $("input[name='checkPw']").val();
			if(input == check){	
				$('#pwCheck input + span').css('color','#0077FF'); 
				$('#pwCheck .border').css('background','#0077FF');
				$('#pwCheck input').css('border-bottom','2px solid #0077FF');
				$("#pwckError").text("비밀번호 확인 완료");
				$inputEmail.focus();
			}else{
				$('#pwCheck input + span').css('color','#a30404'); 
				$('#pwCheck .border').css('background','#a30404');
				$('#pwCheck input').css('border-bottom','2px solid #a30404');		
				$("#pwckError").text("비밀번호가 틀렸습니다");
			}
		}
	})
	
	// 이메일 입력창에서 enter누를때
	$inputEmail.bind("keydown", function(event) {
		if(event.which == 13) {
			var exptext = /^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-Za-z0-9\-]+/;
			if($inputEmail.val() == ""){	
				$('#email input + span').css('color','#a30404');
				$('#email .border').css('background','#a30404');
				$('#email input').css('border-bottom','2px solid #a30404'); 
				$("#emailError").text("이메일이 입력되지않았습니다");	
			}else if(exptext.test($inputEmail.val())==false){
				$('#email input + span').css('color','#a30404');
				$('#email .border').css('background','#a30404');
				$('#email input').css('border-bottom','2px solid #a30404'); 
				$("#emailError").text("이메일형식이 아닙니다");
			}else{
				$('#email input + span').css('color','#0077FF'); 
				$('#email .border').css('background','#0077FF');
				$('#email input').css('border-bottom','2px solid #0077FF');
				$("#emailError").text("이메일 확인완료");
				$("#next").click();
			}
		}
	});
	
	// tab키로 넘어갈때를 입력값이 있으면 확인
	$inputEmail.focusout(function(){
		var exptext = /^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-Za-z0-9\-]+/;
		if($inputEmail.val() ==""){	
			$('#email input + span').css('color','#a30404');
			$('#email .border').css('background','#a30404');
			$('#email input').css('border-bottom','2px solid #a30404'); 
			$("#emailError").text("이메일이 입력되지않았습니다");	
		}else if(exptext.test($inputEmail.val())==false){
			$('#email input + span').css('color','#a30404');
			$('#email .border').css('background','#a30404');
			$('#email input').css('border-bottom','2px solid #a30404'); 
			$("#emailError").text("이메일형식이 아닙니다");
		}else{
			$('#email input + span').css('color','#0077FF'); 
			$('#email .border').css('background','#0077FF');
			$('#email input').css('border-bottom','2px solid #0077FF');
			$("#emailError").text("이메일 확인완료");
			$("#next").click();
		}	
	});
	
	$("#next").bind("click", function(){
		// 입력값 검사
		if($inputName.val() == ""){
			$('#nameCheck input + span').css('color','#a30404');
			$('#nameCheck .border').css('background','#a30404');
			$('#nameCheck input').css('border-bottom','2px solid #a30404'); 
			$("#nameError").text("이름이 입력되지않았습니다");		
		}else{
			$("#nameCheck").css('opacity','0');	
			$("#nameError").css('opacity','0');	
		}
		if($inputId.val() ==""){
			$('#idCheck input + span').css('color','#a30404'); 
			$('#idCheck .border').css('background','#a30404');
			$('#idCheck input').css('border-bottom','2px solid #a30404');		
			$("#idError").text("아이디가 입력되지않았습니다");			
		}else{
			$("#idCheck").css('opacity','0');
			$("#idError").css('opacity','0');	
		}
		if($inputPw.val() ==""){
			$('#pw input + span').css('color','#a30404'); 
			$('#pw .border').css('background','#a30404');
			$('#pw input').css('border-bottom','2px solid #a30404');		
			$("#pwError").text("비밀번호가 입력되지않았습니다");
		}else{
			$("#pw").css('opacity','0');
			$("#pwError").css('opacity','0');	
		}
		if($checkPw.val() ==""){
			$('#pwCheck input + span').css('color','#a30404'); 
			$('#pwCheck .border').css('background','#a30404');
			$('#pwCheck input').css('border-bottom','2px solid #a30404');		
			$("#pwckError").text("비밀번호확인이 입력되지않았습니다");
		}else{
			$("#pwCheck").css('opacity','0');
			$("#pwckError").css('opacity','0');	
		}
		if($inputEmail.val() ==""){
			$('#email input + span').css('color','#a30404');
			$('#email .border').css('background','#a30404');
			$('#email input').css('border-bottom','2px solid #a30404'); 
			$("#emailError").text("이메일이 입력되지않았습니다");	
		}else{
			$("#email").css('opacity','0');
			$("#emailError").css('opacity','0');	
		}
	
		// 입력하지않은곳으로 포커스 이동
		if($inputName.val() == ""){
			$inputName.focus();	
		}else if($inputId.val() ==""){
			$inputId.focus();		
		}else if($inputPw.val() ==""){
			$inputPw.focus();
		}else if($checkPw.val() ==""){
			$checkPw.focus();
		}else if($inputEmail.val() ==""){
			$inputEmail.focus();	
		}else{
			$.ajax({
				method: "post",
				data:$("#userData").serialize(),
				success:function(result){
					if(result){
						window.location.href="http://localhost/note/main";
					}else{
						alert("가입실패")
					}
				},
				error:function(){
					alert("서버 에러");
				}
			})
		}		
	})	
	
	
	// back : 로그인으로 이동
	$("#back").bind("click", function(){	
		$("#nameCheck").css('opacity','0');	
		setTimeout(function() {$("#idCheck").css('opacity','0');}, 500);
		setTimeout(function() {$("#pw").css('opacity','0');}, 500);
		setTimeout(function() {$("#pwCheck").css('opacity','0');}, 500);
		setTimeout(function() {$("#email").css('opacity','0');}, 500);	
		setTimeout(function() {
			$(".demo").css('height','30rem');
			$("#back").css('top','23rem');
			$("#next").css('top','23rem');
		}, 500);
		setTimeout(function() {$("#back").css('opacity','0');}, 500);
		setTimeout(function() {$("#next").css('opacity','0');}, 500);
		setTimeout(function() {window.location.href="http://localhost/note/logout";}, 1200);
	});
})
</script>

<style>
@import "/note/css/user.css";
#idError{font-size: 1em;}
.inp{
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

#nameError{
	opacity: 1;
	transition-duration:1s;
}
#idError{
	opacity: 1;
	transition-duration:1s;
}
#pwError{
	opacity: 1;
	transition-duration:1s;
}
#pwckError{
	opacity: 1;
	transition-duration:1s;
}
#emailError{
	opacity: 1;
	transition-duration:1s;
}
</style>

</head>
<body>
<form method="post" id="userData">
	<div class="cont">
		<div class="demo">
			<div class="login">
				<label for="inp" class="inp" id="nameCheck"><input type="text" name="userName" placeholder="&nbsp;" autocomplete="off"><span class="label">이름</span><span class="border"></span></label>
				<p id="nameError">&nbsp;</p>
				<label for="inp" class="inp" id="idCheck"><input type="text" name="userId" placeholder="&nbsp;" autocomplete="off"><span class="label">아이디</span><span class="border"></span></label>
				<p id="idError">&nbsp;</p>
				<label for="inp" class="inp" id="pw"><input type="password" name="userPw" placeholder="&nbsp;"><span class="label">비밀번호</span><span class="border"></span></label>
				<p id="pwError">&nbsp;</p>
				<label for="inp" class="inp" id="pwCheck"><input type="password" name="checkPw" placeholder="&nbsp;"><span class="label">비밀번호확인</span><span class="border"></span></label>
				<p id="pwckError">&nbsp;</p>
				<label for="inp" class="inp" id="email"><input type="email" name="userEmail" placeholder="&nbsp;"><span class="label">이메일</span><span class="border"></span></label>
				<p id="emailError">&nbsp;</p>
				<button type="button" id="back"><img src="img/back.png"></button>
				<button type="button" id="next"><img src="img/next.png"></button>
			</div>
		</div>
	</div>
</form>
</body>
</html>