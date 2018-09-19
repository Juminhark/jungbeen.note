<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jungbeen.note.page.domain.Page, java.util.List" %>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="/note/js/utility.js"></script>
<script>
window.onload = function() {	
	var note = document.getElementsByClassName("note")[0];
	var pageBgs = note.getElementsByClassName("page-bg");
	var back = document.getElementsByClassName("back")[0];
	var iframe = document.getElementsByTagName("iframe")[0];
	var form = document.getElementsByTagName("form")[0];
	
	function getCssVar(variable) {
		return document.querySelector(":root").style.getPropertyValue("--" + variable);
	}
	
	function setCssVar(name, value) {
		document.querySelector(":root").style.setProperty("--" + name, value);
	}
	
	var n = pageBgs.length; //대상의 갯수.
	var l = document.getElementsByClassName("note")[0].offsetWidth / n; //각각의 대상의 너비
	
	for(var i = 0; i < pageBgs.length; i++) {
		pageBgs[i].style.width = l + "px";
	}
	window.onresize = function() {
		l = document.getElementsByClassName("note")[0].offsetWidth / n;
		for(var i = 0; i < pageBgs.length; i++) {
			pageBgs[i].style.width = l + "px";
		}
	}

	for(var i = 0; i < pageBgs.length; i++) {
		pageBgs[i].onmouseenter =function() {
			this.previousElementSibling.style.visibility = "visible";
			
			var m = 5; //선택된 대상의 좌우로 m개 만큼의 대상들의 간격을 넓힌다.
			var n = pageBgs.length; //대상의 갯수.
			var l = document.getElementsByClassName("note")[0].offsetWidth / n; //각각의 대상의 너비

			var targetIdx = 0;
			for(var i = 0; i < pageBgs.length; i++) {
				if(pageBgs[i] == this) {
					targetIdx = i;
					break;
				}
			}

			var mCnt = 0;
			for(var i = 0; i < m-1; i++) {
				if(i == 0)
					mCnt += m-i;
				else {
					if(0 <= targetIdx - i && targetIdx + i < n)
						mCnt += 2 * (m-i);
					else if(0 <= targetIdx - i)
						mCnt += m-i;
					else
						mCnt += m-i;
				}
			}

			//선택된 대상들
			for(var i = 0; i < m-1; i++) {
				if(0 <= targetIdx - i && targetIdx + i < n) {
					pageBgs[targetIdx-i].style.width = l * (m-i) + "px";
					pageBgs[targetIdx+i].style.width = l * (m-i) + "px";
				} else if (0 <= targetIdx - i)
					pageBgs[targetIdx-i].style.width = l * (m-i) + "px";
				else
					pageBgs[targetIdx+i].style.width = l * (m-i) + "px";
			}

			//선택되지 않은 대상들
			for(var i = 0; i < pageBgs.length; i++) {
				if(i <= targetIdx - m || targetIdx + m < i	) {
					pageBgs[i].style.width = l - ( l * ( mCnt ) ) / ( n - 1 + 2 * (m-1) ) + "px";
				}
			}
		}

		pageBgs[i].onmouseleave = function(e) {
			this.previousElementSibling.style.visibility = "hidden";

			e.preventDefault();
			
			var n = pageBgs.length; //대상의 갯수.
			var l = document.getElementsByClassName("note")[0].offsetWidth / n; //각각의 대상의 너비

			for(var i = 0; i < pageBgs.length; i++) {
				pageBgs[i].style.width = l + "px";
			}
		}
		pageBgs[i].onmousedown = function(e) {
			var meta = this.getElementsByClassName("meta")[0];
			var pageBg = this;
			var page = pageBg.children[0];
			
			page.style.visibility = "hidden";
			
			iframe.style.left = page.getBoundingClientRect().left + "px";
			iframe.style.top = page.getBoundingClientRect().top + "px";
			iframe.style.width = "2.5px";
			iframe.style.height = pageBg.offsetHeight + "px";
			
			form.children[0].setAttribute("value", <%= request.getAttribute("noteId") %>);
			form.children[1].setAttribute("value", meta.children[0].innerText);
			form.children[2].click();
		}
		pageBgs[i].onmouseup = function(e) {
			iframe.style.display = "block";
			
			setTimeout(function() {
				iframe.style.left = "0px";
				iframe.style.top = "0px";
				
				iframe.style.width = "100%";
				iframe.style.height = "100%";
			}, 50);
			
		}
	}
	
	setTimeout(function() {
		for(var i = 0; i < pageBgs.length; i++)
			pageBgs[i].style.transitionDuration = "0.5s";
	}, 500);
	
	back.onclick = function() {
		for(var i = 0; i < pageBgs.length; i++)
			pageBgs[i].style.transitionDuration = "0s";
		window.parent.postMessage(<%= request.getAttribute("noteIdx") %>, "*");
	}
	
	function sync() {
		ajax({
			url:"/note/page/downContent",
			method:"post",
			param:[{name:"noteId", value:"<%= ((List<Page>)request.getAttribute("pages")).get(0).getNoteId() %>"}],
			success:function(response) {
				for(var i = 0; i < response.length; i++) {
					var preview = pageBgs[i].previousElementSibling;
					var text = getPreview(html2text(response[i].content1).trim());
					
					if(text != null)
						text = text.length > 20 ? text.substring(0, 20) + " ..." : text;
						
					preview.innerHTML = text.trim();
				}
			}
		});
	}
	
	function getPreview(text) {
		return text.replace(/\r\n/g, "\r").replace(/\n/g, "\r").split(/\r/)[0];
	}
	
	function html2text(html) {
	    var tag = document.createElement('div');
	    tag.innerHTML = html;
	    
	    return tag.innerText;
	}
	
	sync();
	
	window.onmessage = function(e) {
		var pageBg = pageBgs[Number(e.data)];
		var page = pageBg.children[0];
		
		iframe.style.left = page.getBoundingClientRect().left;
		iframe.style.top = page.getBoundingClientRect().top;
		iframe.style.width = "2.5px";
		iframe.style.height = pageBg.offsetHeight + "px";
		
		sync();
		
		setTimeout(function() {
			page.style.visibility = "visible";
			iframe.style.display = "none";
		}, 500);
	}
	
	function fontSize(ratio) {
		var size;
		
		if(window.innerWidth < window.innerHeight)
			size = window.innerWidth * ratio;
		else
			size = window.innerHeight * ratio;
		
		for(var i = 0; i < pageBgs.length; i++) {
			var preview = pageBgs[i].previousElementSibling;
			preview.style.fontSize = size + "px";
		}
	}
}
</script>
<style>
	.note {
	    position: fixed;

	    width:80%;
	    height:30%;

	    left:10%;
	    top: 35%;
	}
	
	.note .preview {
		position:fixed;
		visibility:hidden;
		
		width: 80%;
	    height:20%;
	    
	    left:10%;
	    top:10%;
	    
	    color:white;
	    text-align:center;
	    font-size:3em;
	    font-weight:300;
	    text-shadow:0px 2.5px 10px rgba(0, 0, 0, 0.5);
	    
	    overflow:hidden;
	}
	
	.note .page-bg {
	    display: inline-block;
	    
	    height: 100%;
	    
	    text-align: center;
	    
	    margin-left: -5.7px;
	    
	    cursor:pointer;
	    
	    transition-duration: 0s;
	}
	
	.note .page{
		position: absolute;
	    display: inline;
	    
	    width: 2.5px;
	    height: 100%;
	    
	    background-color:#F8ECE0;
	}
	
	.page-bg:hover .page{
	    background-color: red;
	}
	.note .meta {
		display:none;
	}
	iframe {
		position:fixed;
		display:none;
	
		width: 2.5px;
	    height: calc(297px * var(--page-size-ratio));
	    
	    left:0px;
	    top:0px;
	    
	    z-index:5;
	    
	    transition-duration:0.5s;
	}
	form {
		display:none;
	}
	
	body {
		background-color:none transparent;
		
		overflow:hidden;
	}
	.back {
		position:fixed;
		
		left:0%;
		top:0%;
		width:100%;
		height:100%;
		
		cursor:pointer;
	}
</style>
</head>
<body>
	<div class="back"></div>
	
	<form method="post" action="/note/page" target="pageFrame">
		<input type="hidden" name="noteId" value="">
		<input type="hidden" name="pageIdx" value="">
		<input type="submit">
	</form>
	
	<iframe name="pageFrame" allowtransparency="true" frameborder="0" width="30px" height="300px"></iframe>
	
    <div class="note">
<%
	List<Page> pages = (List<Page>)request.getAttribute("pages");

	for(Page p : pages) {   
%>
    	<div class="preview"><%= p.getContent1() == null ? "" : p.getContent1() %></div>
        <div class="page-bg">
        	<div class="page"></div>
        	<div class="meta">
        		<div class="idx"><%= p.getIdx() %></div>
        	</div>
        </div>
<%
	}
%>
    </div>
</body>
</html>

