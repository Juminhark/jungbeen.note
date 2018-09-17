<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="jungbeen.note.page.domain.Page" %>
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="/note/js/RangeEx.js"></script>
<script src="/note/js/utility.js"></script>
<script>
window.onload = function() {
	var page = document.getElementsByClassName("page")[0];
	var back = document.getElementsByClassName("back")[0];
	
	var tm = document.getElementsByClassName("text-menu")[0];
	
	var size = tm.getElementsByClassName("size")[0];
		var sizeIn = tm.getElementsByClassName("size-in")[0];
		
	var style = tm.getElementsByClassName("style")[0];
		var weight = tm.getElementsByClassName("weight")[0];
			var weightIn = tm.getElementsByClassName("weight-in")[0];
			
		var color = tm.getElementsByClassName("color")[0];
			var colors = tm.getElementsByClassName("colors")[0];
			
		var lineThrough = tm.getElementsByClassName("line-through")[0];
			var lines = tm.getElementsByClassName("lines")[0];
			
	var mark = tm.getElementsByClassName("mark")[0];
		var markColors = tm.getElementsByClassName("mark-colors")[0];
	
	var align = tm.getElementsByClassName("align")[0];
		var aligns = tm.getElementsByClassName("aligns")[0];
	
	var erase = tm.getElementsByClassName("erase")[0];
	
	function setPageSizeRatio(ratio) {
		var pageSizeRatio = 1;
		
		if(window.innerWidth < window.innerHeight * 0.7070) {
			pageSizeRatio = window.innerWidth / 210;
		} else {
			pageSizeRatio = window.innerHeight / 297;
		}
		pageSizeRatio -= pageSizeRatio % 1;
		
		if(pageSizeRatio == 0)
			pageSizeRatio = 1;
		
		pageSizeRatio *= ratio;
		setCssVar("page-size-ratio", pageSizeRatio);
	}

	function sync(success) {
		var content = page.innerHTML;
		
		content = content.replace(/&nbsp;/g, " ");
		content = content.replace(/&[a-z.]*;/g, "");
		
		var content1 = "";
		var content2 = "";
		var content3 = "";
		var content4 = "";
		var content5 = "";
		
		if(0 <= content.length && content.length < 4000)
			content1 = content.substring(0, content.length);
		else if(4000 <= content.length && content.length < 8000) {
			
			content1 = content.substring(0, 4000);
			content2 = content.substring(4000, content.length);
			
		} else if(8000 <= content.length && content.length < 12000) {
			
			content1 = content.substring(0, 4000);
			content2 = content.substring(4000, 8000);
			content3 = content.substring(8000, content.length);
			
		} else if(12000 <= content.length && content.length < 16000) {
			
			content1 = content.substring(0, 4000);
			content2 = content.substring(4000, 8000);
			content3 = content.substring(8000, 12000);
			content4 = content.substring(12000, content.length);
			
		} else if(16000 <= content.length && content.length < 20000) {
			
			content1 = content.substring(0, 4000);
			content2 = content.substring(4000, 8000);
			content3 = content.substring(8000, 12000);
			content4 = content.substring(12000, 16000);
			content5 = content.substring(16000, content.length);
			
		}
		
		ajax({
			url:"/note/page/upContent",
			method:"post",
			param:[
			       {name:"id", value:"<%= ((Page)request.getAttribute("page")).getId() %>"},
			       {name:"content1", value:content1},
			       {name:"content2", value:content2},
			       {name:"content3", value:content3},
			       {name:"content4", value:content4},
			       {name:"content5", value:content5}
			       ],
			success:success
		});
	}
	
	setPageSizeRatio(0.8);
	window.onresize = function() {
		setPageSizeRatio(0.8);
	}
	
	page.onkeydown = function(e) {
		sync(function(r) {
			if(!r)
				console.log("글자 수 제한을 초과하였습니다.");
		});
		
	    if (e.keyCode === 9) { // tab key
	        e.preventDefault();  // this will prevent us from tabbing out of the editor

			//RangeEx.insertNode({text:"    "});
	    }
	}
	
	page.oncontextmenu = function(e) {
		e.preventDefault();
		
		var sel = window.getSelection();
		var cursor = sel.anchorNode.parentElement;
		
		if(sel.isCollapsed) {
			if(cursor.getAttribute("style") != undefined &&
					findAncestor(cursor, page)) {
				var firstChild = cursor.firstChild;
				while(firstChild.wholeText != cursor.innerText)
					firstChild = firstChild.nextSibling;
				
				var lastChild = cursor.lastChild;
				while(lastChild.wholeText != cursor.innerText)
					lastChild = lastChild.previousSibling;
				
				console.log(firstChild);
				console.log(lastChild);
				
			    var sel = RangeEx.setRange({
			    	startNode:firstChild == null ? cursor : firstChild, 
			    	endNode:lastChild == null ? cursor : lastChild
			    });
			    
				RangeEx.surroundContents({
					tagName:"span",
					attribute:[
					           {name:"data-select", value:"selected"},
					           {name:"style", value:"background-color:#D8D8D8"}
					]
				});

				erase.onclick = function() {
					var target = document.querySelectorAll("[data-select='selected']");
					
					var sel = RangeEx.setRange({
				    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
				    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
				    });
				    
			    	RangeEx.releaseContents({
						range:sel.getRangeAt(0),
						root:page,
						attribute:[{name:"style"}]
					});
				}
				
				popup(e.clientX, e.clientY, 200, 40);
			}
		}
	}

	page.onmousedown = function(e) {
		reset();
		
		if(e.which == 1) {
			//밑줄표시를 위해 data-select 속성을 가진 SPAN객체가 삽입되면,
			//그 객체의 양 옆에 아무런 글자도 없음을 나타내는 유니코드가 생기는 것 같다.
			//그리고 surroundContents 함수는 그 유니코드도 SPAN으로 감싼다.
			//이런 과정이 반복되면 SPAN객체가 수없이 많아져 프로그램이 둔해진다.
			//따라서 모든 유니코드를 제거하는 코드를 아래와 같이 추가하였다.
			page.innerHTML = page.innerHTML.replace(/&[a-z.]*;/g, "");
			
			while(document.querySelector("[data-select='selected']")) {
				var target = document.querySelector("[data-select='selected']");
				
				while(target.firstChild)
					target.parentNode.insertBefore(target.firstChild, target);
				
				target.parentNode.removeChild(target);
			}
		}
	}
	
	page.onmouseup = function(e) {
		var sel = window.getSelection();
		var cursor = sel.anchorNode.parentElement;
		
		if(e.which == 1)
			if(!sel.isCollapsed && findAncestor(cursor, page)) {			
				RangeEx.surroundContents({
					tagName:"span",
					attribute:[
					           {name:"data-select", value:"selected"},
					           {name:"style", value:"background-color:#D8D8D8"}
					]
				});
				
				popup(e.clientX, e.clientY);
			}
	}

	page.ondragover = function(e) {
		e.preventDefault();
		
		var droppedNode = document.elementFromPoint(e.clientX, e.clientY);
		
		if(droppedNode == page)
			droppedNode = page.lastChild;
		
		if(droppedNode != null)
			RangeEx.setRange({	
				startNode:droppedNode.firstChild,
				endNode:droppedNode.lastChild
			});
	}
	
	page.ondragenter = function(e) {
		e.preventDefault();
	}

	page.ondrop = function(e) {
		e.preventDefault();
		
		var droppedNode = document.elementFromPoint(e.clientX, e.clientY);
		if(droppedNode == page)
			droppedNode = page.lastChild;
		
		var files = e.dataTransfer.files;
		for(var i = 0; i < files.length; i++) {
			var fd = new FormData();
			fd.append("uploadFile", files[i]);
			
			ajax({
				url:"/note/page/upFile",
				method:"post",
				data:fd,
				serialize:true,
				success:function(response) {
					var isPng = response.split(".")[1] == "png";
					
					if(droppedNode != null) {
						var sel = RangeEx.setRange({
					    	startNode:droppedNode.firstChild == null ? droppedNode : droppedNode.firstChild,
					    	endNode:droppedNode.lastChild == null ? droppedNode : droppedNode.lastChild
					    });
						
						if(isPng)
							RangeEx.insertNode({
								range:sel.getRangeAt(0),
								tagName:"img",
								attribute:[
									{name:"src", value:"/note/upload/" + response}
								]
							});
						else
							RangeEx.insertNode({
								range:sel.getRangeAt(0),
								tagName:"img",
								attribute:[
									{name:"src", value:"/note/upload/" + response},
									{name:"style", value:"box-shadow:0px 5px 10px 1px rgba(0, 0, 0, 0.5)"}
								]
							});
					} else {
						var img = document.createElement("img");
						img.setAttribute("src", "/note/upload/" + response);
						if(!isPng)
							img.setAttribute("style", "box-shadow:0px 5px 10px 1px rgba(0, 0, 0, 0.5)");
						
						page.appendChild(img);
					}
				}
			});
		}
	}
	
	//text-menu
	function hide(el) {
		el.style.display = "none";
	}
	
	function show(el) {
		el.style.display = "block";
	}
	
	function reset(width, height) {
		hide(tm);
		
		if(width != undefined)
			tm.style.width = width + "px";
		
		if(height != undefined)
			tm.style.height = height + "px";
		
		hide(size);
			hide(sizeIn);
				sizeIn.children[1].value = "";
			
		hide(style);
			hide(weight);
				
			hide(color);
				hide(colors);
				colors.children[6].children[0].value = "";
				
			hide(lineThrough);
				hide(lines);
				
		hide(mark);
			hide(markColors);
			markColors.children[6].children[0].value = "";
			
		hide(align);
			hide(aligns);
			
		hide(erase);
	}
		
	function popup(left, top, width, height) {
		reset(width ? width : 160, height ? height : 40);
		
		tm.style.left = left + "px";
		tm.style.top = top + "px";
		
		show(tm);
		show(size);
		show(style);
		show(mark);
		show(align);
		
		if(width && height) {
			show(erase);
			align.style.borderRadius = "0px 0px 0px 0px";
		} else {
			hide(erase);
			align.style.borderRadius = "0px 5px 5px 0px";
		}
	}
	
	sizeIn.children[1].onkeydown = function(e) {
		if(e.keyCode == 13) {
			var fontSize = sizeIn.children[1].value;
			
			setTimeout(function() {
				var target = document.querySelectorAll("[data-select='selected']");
			    
				var sel = RangeEx.setRange({
			    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
			    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
			    });
			    
			    RangeEx.surroundContents({
		    		range:sel.getRangeAt(0),
					tagName:"span",
					attribute:[{name:"style", value:"font-size:" + fontSize + "px"}]
				});	
			}, 50);
		}
	}
	
	weight.onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
    		range:sel.getRangeAt(0),
			tagName:"span",
			attribute:[{name:"style", value:"font-weight:bolder"}]
		});	
	}
	
	for(var i = 0; i < colors.children.length; i++) {
		var col = colors.children[i];
		
		if(i < 6) {
			col.onclick = function() {
				var rgba = getStyle(this, "background-color");

				var target = document.querySelectorAll("[data-select='selected']");

			    var sel = RangeEx.setRange({
			    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
			    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
			    });
			    
			    RangeEx.surroundContents({
		    		range:sel.getRangeAt(0),
					tagName:"span",
					attribute:[{name:"style", value:"color:"+rgba}]
				});
			}
		} else {
			col.children[0].onkeydown = function(e) {
				if(e.keyCode == 13) {
					var rgba = this.value;
					var exit = false;
					
					//db의 maxLength 는 24이다.
					if(rgba.length <= 24) {
						if(rgba.substring(0, 4) != "rgba")
							if(rgba.split(",").length == 4)
								rgba = "rgba(" + rgba + ")";
							else if(rgba.split(",").length == 3)
								rgba = "rgba(" + rgba + ", 1)";
							else if(rgba.split(" ").length == 4)
								rgba =  "rgba(" + rgba.split(" ")[0] + ", " + rgba.split(" ")[1] + ", " + rgba.split(" ")[2] + ", " + rgba.split(" ")[3] + ")";
							else if(rgba.split(" ").length == 3)
								rgba =  "rgba(" + rgba.split(" ")[0] + ", " + rgba.split(" ")[1] + ", " + rgba.split(" ")[2] + ", 1)";
							else
								exit = true;
						
						if(!exit) {
							setTimeout(function() {
								var target = document.querySelectorAll("[data-select='selected']");
							    
								var sel = RangeEx.setRange({
							    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
							    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
							    });
							    
							    RangeEx.surroundContents({
						    		range:sel.getRangeAt(0),
									tagName:"span",
									attribute:[{name:"style", value:"color:"+rgba}]
								});
							}, 50);
						}
					}
				}
			}
		}
	}
	
	//overline
	lines.children[0].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
    		range:sel.getRangeAt(0),
			tagName:"span",
			attribute:[{name:"style", value:"text-decoration:overline"}]
		});
	}
	
	//line-through
	lines.children[1].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
    		range:sel.getRangeAt(0),
			tagName:"span",
			attribute:[{name:"style", value:"text-decoration:line-through"}]
		});
	}
	
	//underline
	lines.children[2].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
    		range:sel.getRangeAt(0),
			tagName:"span",
			attribute:[{name:"style", value:"text-decoration:underline"}]
		});
	}
	
	for(var i = 0; i < markColors.children.length; i++) {
		var markColor = markColors.children[i];
		
		if(i < 6) {
			markColor.onclick = function() {
				var rgba = getStyle(this, "background-color");
				
				var target = document.querySelectorAll("[data-select='selected']");
			    
				var sel = RangeEx.setRange({
			    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
			    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
			    });
			    
			    RangeEx.surroundContents({
		    		range:sel.getRangeAt(0),
					tagName:"span",
					attribute:[{name:"style", value:"background-color:"+rgba}]
				});
			}
		} else {
			markColor.children[0].onkeydown = function(e) {
				if(e.keyCode == 13) {
					var rgba = this.value;
					var exit = false;
					
					//db의 maxLength 는 24이다.
					if(rgba.length <= 24) {
						if(rgba.substring(0, 4) != "rgba")
							if(rgba.split(",").length == 4)
								rgba = "rgba(" + rgba + ")";
							else if(rgba.split(",").length == 3)
								rgba = "rgba(" + rgba + ", 1)";
							else if(rgba.split(" ").length == 4)
								rgba =  "rgba(" + rgba.split(" ")[0] + ", " + rgba.split(" ")[1] + ", " + rgba.split(" ")[2] + ", " + rgba.split(" ")[3] + ")";
							else if(rgba.split(" ").length == 3)
								rgba =  "rgba(" + rgba.split(" ")[0] + ", " + rgba.split(" ")[1] + ", " + rgba.split(" ")[2] + ", 1)";
							else
								exit = true;
						
						if(!exit) {
							setTimeout(function() {
								var target = document.querySelectorAll("[data-select='selected']");
							    
								var sel = RangeEx.setRange({
							    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
							    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
							    });
							    
							    RangeEx.surroundContents({
						    		range:sel.getRangeAt(0),
									tagName:"span",
									attribute:[{name:"style", value:"background-color:"+rgba}]
								});
							}, 50);
						}
					}
				}
			}
		}
	}

	//left
	aligns.children[0].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
			range:sel.getRangeAt(0),
			tagName:"div",
			attribute:[{name:"style", value:"text-align:left"}]
		});
	}
	
	//center
	aligns.children[1].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
			range:sel.getRangeAt(0),
			tagName:"div",
			attribute:[{name:"style", value:"text-align:center"}]
		});
	}
	
	//right
	aligns.children[2].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
			range:sel.getRangeAt(0),
			tagName:"div",
			attribute:[{name:"style", value:"text-align:right"}]
		});
	}
	
	//justify
	aligns.children[0].onclick = function() {
		var target = document.querySelectorAll("[data-select='selected']");
	    
		var sel = RangeEx.setRange({
	    	startNode:target[0].firstChild == null ? target[0] : target[0].firstChild,
	    	endNode:target[target.length-1].lastChild == null ? target[target.length-1] : target[target.length-1].lastChild
	    });
	    
	    RangeEx.surroundContents({
			range:sel.getRangeAt(0),
			tagName:"div",
			attribute:[{name:"style", value:"text-align:justify"}]
		});
	}
	
	//erase는 page.oncontextmenu에서 handler를 등록했다.
	
	//default click handler
	size.onclick = function() {
		
		reset(120, 40);
	
		show(tm);
		show(sizeIn);
		sizeIn.children[1].focus();
	}
	
	style.onclick = function() {
		
		reset(120, 40);
		
		show(tm);
		show(weight);
		show(color);
		show(lineThrough);
		
		color.onclick = function() {
			
			reset(120, 120);
			
			show(tm);
			show(colors);
			colors.children[colors.children.length-1].children[0].focus();
		}
		
		lineThrough.onclick = function() {
			
			reset(120, 40);
			
			show(tm);
			show(lines);
		}
	}
	
	mark.onclick = function() {
		
		reset(120, 120);
		
		show(tm);
		show(markColors);
		markColors.children[6].children[0].focus();
	}
	
	align.onclick = function() {
		
		reset(160, 40);
		
		show(tm);
		show(aligns);
	}
	
	back.onclick = function() {
		triggerEvent(page, "mousedown");
		
		sync(function(r) {
			if(r)
				window.parent.postMessage(<%= ((Page)request.getAttribute("page")).getIdx() %>, "*");
			else
				console.log("글자 수 제한을 초과하였습니다.");
		});
	}
}
</script>
<style>
/* width */
::-webkit-scrollbar {
	left:100%;
    width: 10px;
}

/* Track */
::-webkit-scrollbar-track {
    
}

/* Handle */
::-webkit-scrollbar-thumb {
    background: #D8D8D8;
}

/* Handle on hover */
::-webkit-scrollbar-thumb:hover {
    background: gray; 
}
::selection {
	background-color:#D8D8D8;
}
.page img {
	width:100%;
	border-radius:1%;
}
:root {
	--page-size-ratio:1;
	
	--icon-standard-size:calc(297px * var(--page-size-ratio) / 30);
	--icon-color:white;
	--icon-shadow:0px 0px 5px gray;
}
.page {	
	position:absolute;
	padding:60px;
	overflow:auto;
	
	width:calc(210px * var(--page-size-ratio, 1));
	height:calc(297px * var(--page-size-ratio, 1));
	left:calc(50% - 60px - (210px * var(--page-size-ratio, 1) / 2));
	top:calc(50% - 60px - (297px * var(--page-size-ratio, 1) / 2));	
	
	box-shadow:0px 5px 10px 1px rgba(0, 0, 0, 0.5);
	border-style:none;
	outline-style:none;
	background-color:white;
	
	transition-duration:0.5s;
}

.page:active {
	border-style:none;
	outline-style:none;
}

.text-menu {
	position:fixed;
	display:none;
	
	width:160px;
	height:40px;
	
	left:0px;
	top:240px;
	
	border-radius:5px;
	background-color:#f2f2f2;
	box-shadow:0px 5px 10px 1px rgba(0, 0, 0, 0.5);
	
	transition-duration:0.25s;
}
/*text size ~*/
.text-menu .size {
	position:absolute;
	display:block;
	
	width:40px;
	height:100%;
	
	left:0px;
	top:0px;
	
	border-radius:5px 0px 0px 5px;
}
	.text-menu .size-in {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
	}
		.text-menu .size-in input {
			position:absolute;
			
			width:70%;
			height:100%;
			
			left:15%;
			top:0px;
			
			border-radius:5px;
		}
/*~ text size*/

/*text style ~*/
.text-menu .style {
	position:absolute;
	display:block;
	
	width:40px;
	height:100%;
	
	left:40px;
	top:0px;
}
	.text-menu .weight {
		position:absolute;
		display:none;
		
		width:33.3%;
		height:100%;
		
		left:0px;
		top:0px;
		
		border-radius:5px 0px 0px 5px;
	}
		.text-menu .weight-in {
			position:absolute;
			display:none;
			
			width:100%;
			height:100%;
			
			left:0px;
			top:0px;
			
			border-radius:5px;
		}
			.text-menu .weight-in input {
				position:absolute;
				
				width:70%;
				height:100%;
				
				left:15%;
				top:0px;
			}
			
	.text-menu .color {
		position:absolute;
		display:none;
		
		width:33.3%;
		height:100%;
		
		left:33.3%;
		top:0px;
	}
		.text-menu .colors {
			position:absolute;
			display:none;
			
			width:100%;
			height:100%;
			
			left:0px;
			top:0px;
			
			border-radius:5px;
		}
		.text-menu .colors:hover {background-color:transparent;}
			.text-menu .colors>* {position:absolute; width:33.3%; height:33.3%; transition-duration:0.25s;}
			.text-menu .colors .color-1:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			.text-menu .colors .color-2:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			.text-menu .colors .color-3:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			.text-menu .colors .color-4:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			.text-menu .colors .color-5:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			.text-menu .colors .color-6:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
			
			.text-menu .colors .color-1 {background-color:#000000; left:0%; top:0%; border-radius:5px 0px 0px 0px;}
			.text-menu .colors .color-2 {background-color:#005960; left:33.3%; top:0%;}
			.text-menu .colors .color-3 {background-color:#2E4A62; left:66.6%; top:0%; border-radius:0px 5px 0px 0px;}
			.text-menu .colors .color-4 {background-color:#794044; left:0%; top:33.3%;}
			.text-menu .colors .color-5 {background-color:#FF4444; left:33.3%; top:33.3%;}
			.text-menu .colors .color-6 {background-color:#EFC050; left:66.6%; top:33.3%;}
			.text-menu .colors .rgba-in {width:100%; height:33.3%; top:66.6%; border-radius:0px 0px 5px 5px;}
				.text-menu .colors .rgba-in input {
					position:absolute;
					
					width:100%;
					height:100%;
					
					left:0px;
					top:0px;
					
					text-align:center;
					
					border-radius:0px 0px 5px 5px;
				}
				.text-menu .colors .rgba-in:hover {box-shadow:none;}
	.text-menu .line-through {
		position:absolute;
		display:none;
		
		width:33.3%;
		height:100%;
		
		left:66.6%;
		top:0px;
		
		border-radius:0px 5px 5px 0px;
	}
		.text-menu .lines {
			position:absolute;
			display:none;
			
			width:100%;
			height:100%;
			
			left:0px;
			top:0px;
			
			border-radius:5px;
		}
			.text-menu .lines>* {
				position:absolute; 
				
				width:33.3%; 
				height:100%;
			}
			.text-menu .lines>* span {
					--length:25px;
					position:absolute;
					
					width:var(--length);
					height:var(--length);
					
					left:calc(50% - var(--length) / 2);
					top:calc(50% - var(--length) / 2 - 7px);
					
					font-weight:bold;
					font-size:25px;
			}
			.text-menu .lines .top {left:0%; top:0%; border-radius:5px 0px 0px 5px;}
			.text-menu .lines .middle {left:33.3%; top:0%;}
			.text-menu .lines .bottom {left:66.6%; top:0%; border-radius:0px 5px 5px 0px;}

/*mark ~*/
.text-menu .mark {
	position:absolute;
	display:block;
	
	width:40px;
	height:100%;
	
	left:80px;
	top:0px;
}
	.text-menu .mark-colors {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
		
		left:0px;
		top:0px;
		
		border-radius:5px;
	}
	.text-menu .mark-colors:hover {background-color:transparent;}
		.text-menu .mark-colors>* {position:absolute; width:33.3%; height:33.3%; transition-duration:0.25s;}
		.text-menu .mark-colors .color-1:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		.text-menu .mark-colors .color-2:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		.text-menu .mark-colors .color-3:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		.text-menu .mark-colors .color-4:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		.text-menu .mark-colors .color-5:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		.text-menu .mark-colors .color-6:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
		
		.text-menu .mark-colors .color-1 {background-color:#F1EA7F; left:0%; top:0%; border-radius:5px 0px 0px 0px;}
		.text-menu .mark-colors .color-2 {background-color:#BE9EC9; left:33.3%; top:0%;}
		.text-menu .mark-colors .color-3 {background-color:#B4B7BA; left:66.6%; top:0%; border-radius:0px 5px 0px 0px;}
		.text-menu .mark-colors .color-4 {background-color:#92B6D5; left:0%; top:33.3%;}
		.text-menu .mark-colors .color-5 {background-color:#F7786B; left:33.3%; top:33.3%;}
		.text-menu .mark-colors .color-6 {background-color:#BFD641; left:66.6%; top:33.3%;}
		.text-menu .mark-colors .rgba-in {width:100%; left:0%; top:66.6%; border-radius:0px 0px 5px 5px;}
		.text-menu .mark-colors .rgba-in:hover {box-shadow:none;}
			.text-menu .mark-colors .rgba-in input {
				position:absolute;
				
				width:100%;
				height:100%;
				
				border-radius:0px 0px 5px 5px;
			}
/*~ mark*/

/*align ~*/
.text-menu .align {
	position:absolute;
	display:block;
	
	width:40px;
	height:100%;
	
	left:120px;
	top:0px;
	
	border-radius:0px 5px 5px 0px;
}
	.text-menu .aligns {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
		
		left:0px;
		top:0px;
		
		border-radius:5px;
	}
		.text-menu .aligns>* {position:absolute; width:25%; height:100%;}
		.text-menu .aligns .left {left:0%; top:0%; border-radius:5px 0px 0px 5px;}
		.text-menu .aligns .center {left:25%; top:0%;}
		.text-menu .aligns .right {left:50%; top:0%;}
		.text-menu .aligns .justify {left:75%; top:0%; border-radius:0px 5px 5px 0px;}
/*~ align*/

/*erase ~*/
.text-menu .erase {
	position:absolute;
	display:none;
	
	width:40px;
	height:100%;
	
	left:160px;
	top:0px;
	
	border-radius:0px 5px 5px 0px;
}
/*~ erase*/

/*hover ~*/
.text-menu .size:hover {background-color:rgba(256, 256, 256, 0.8);}

.text-menu .style:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .weight:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .color:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .line-through:hover {background-color:rgba(256, 256, 256, 0.8);}
		.text-menu .lines .top:hover {background-color:rgba(256, 256, 256, 0.8);}
		.text-menu .lines .middle:hover {background-color:rgba(256, 256, 256, 0.8);}
		.text-menu .lines .bottom:hover {background-color:rgba(256, 256, 256, 0.8);}

.text-menu .mark:hover {background-color:rgba(256, 256, 256, 0.8);}

.text-menu .align:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .aligns .left:hover:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .aligns .center:hover:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .aligns .right:hover:hover {background-color:rgba(256, 256, 256, 0.8);}
	.text-menu .aligns .justify:hover:hover {background-color:rgba(256, 256, 256, 0.8);}

.text-menu .erase:hover {background-color:rgba(256, 256, 256, 0.8);}

.text-menu button:hover {background-color:rgba(256, 256, 256, 0.8);}
/*~ hover*/

.text-menu input {
	border:0px;
	outline:0px;
	margin:0px;
	padding:0px;
	
	text-align:center;
}
.text-menu button {
	border:0px;
	outline:0px;
	margin:0px;
	padding:0px;
	
	text-align:center;	
}
.text-menu .stepDown {
	position:absolute;
	
	width:15%;
	height:100%;
	
	left:0px;
	top:0px;
	
	border-radius:5px 0px 0px 5px;
}
.text-menu .stepUp {
	position:absolute;
	
	width:15%;
	height:100%;
	
	left:85%;
	top:0px;
	
	border-radius:0px 5px 5px 0px;
}
input[type="number"] {
  -webkit-appearance: textfield;
     -moz-appearance: textfield;
          appearance: textfield;
}
input[type=number]::-webkit-inner-spin-button, 
input[type=number]::-webkit-outer-spin-button { 
  -webkit-appearance: none;
}
.text-menu img {
	--length:25px;
	position:absolute;
	
	width:var(--length);
	height:var(--length);
	
	left:calc(50% - var(--length) / 2);
	top:calc(50% - var(--length) / 2);
}
.text-menu img{background-color:transparent;}
.text-menu input {background-color:transparent;}
.text-menu span {background-color:transparent;}
.text-menu button {background-color:transparent;}

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
<body style="background-color:transparent">

<div class="back"></div>

<div class="page" contenteditable=true>
<%= ((Page)request.getAttribute("page")).getContent1() == null ? "" : ((Page)request.getAttribute("page")).getContent1() %>
<%= ((Page)request.getAttribute("page")).getContent2() == null ? "" : ((Page)request.getAttribute("page")).getContent2() %>
<%= ((Page)request.getAttribute("page")).getContent3() == null ? "" : ((Page)request.getAttribute("page")).getContent3() %>
<%= ((Page)request.getAttribute("page")).getContent4() == null ? "" : ((Page)request.getAttribute("page")).getContent4() %>
<%= ((Page)request.getAttribute("page")).getContent5() == null ? "" : ((Page)request.getAttribute("page")).getContent5() %>
</div>


<div class="text-menu">
	<div class="size"><img src="/note/img/size.png"></div>
		<div class="size-in">
			<button class="stepDown" type="button" onclick="this.nextElementSibling.stepDown(1)">-</button>
			<input type="number" placeholder="px">
			<button class="stepUp" type="button" onclick="this.previousElementSibling.stepUp(1)">+</button>
		</div>
	
	<div class="style"><img src="/note/img/style.png"></div>
		<div class="weight"><img src="/note/img/weight.png"></div>
	
		<div class="color"><img src="/note/img/color.png"></div>
			<div class="colors">
				<div class="color-1"></div>
				<div class="color-2"></div>
				<div class="color-3"></div>
				<div class="color-4"></div>
				<div class="color-5"></div>
				<div class="color-6"></div>
				<div class="rgba-in"><input type="text" placeholder="rgba(r, g, b, a)"></div>
			</div>
	
		<div class="line-through"><img src="/note/img/underline.png"></div>
			<div class="lines">
				<div class="top"><span style="text-decoration:overline; text-align:center;">A</span></div>
				<div class="middle"><span style="text-decoration:line-through; text-align:center;">A</span></div>
				<div class="bottom"><span style="text-decoration:underline; text-align:center;">A</span></div>
			</div>
		
	<div class="mark"><img src="/note/img/mark.png"></div>
		<div class="mark-colors">
			<div class="color-1"></div>
			<div class="color-2"></div>
			<div class="color-3"></div>
			<div class="color-4"></div>
			<div class="color-5"></div>
			<div class="color-6"></div>
			<div class="rgba-in"><input type="text" placeholder="rgba(r, g, b, a)"></div>
		</div>
	
	<div class="align"><img src="/note/img/align-center.png"></div>
		<div class="aligns">
			<div class="left"><img src="/note/img/align-left.png"></div>
			<div class="center"><img src="/note/img/align-center.png"></div>
			<div class="right"><img src="/note/img/align-right.png"></div>
			<div class="justify"><img src="/note/img/align-justify.png"></div>
		</div>
		
	<div class="erase"><img src="/note/img/delete.png"></div>
</div>
</body>