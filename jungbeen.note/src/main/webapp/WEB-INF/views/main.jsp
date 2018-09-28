<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jungbeen.note.user.domain.User, jungbeen.note.note.domain.Note, jungbeen.note.usernote.domain.UserNote" %>
<%@ page import="java.util.List" %>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
<script src="/note/js/utility.js"></script>
<script>
window.onload = function() {
	var notes = document.getElementsByClassName("note");
	var shadows = document.getElementsByClassName("shadow");
	var shelf = document.getElementsByClassName("shelf")[0];
	var iframe = document.getElementsByTagName("iframe")[0];
	var noteForm = document.getElementById("showNote");
	var reForm = document.getElementById("refresh");
	var pusher = document.getElementById("pusher");
	
	//하나의 노트가 삭제되는 동안 
	//다른 노트의 삭제나 노트의 생성이 이루어지면 노트의 인덱스가
	//꼬이게 된다.
	//그것을 막기 위한 변수이다.
	var ondeleting = false;
	
	var onLifting = false;

	var pm = document.getElementsByClassName("popup-menu")[0];
	
	var edit = pm.getElementsByClassName("edit")[0];
		var name = pm.getElementsByClassName("name")[0];
			var nameIn = pm.getElementsByClassName("name-in")[0];
		var color = pm.getElementsByClassName("color")[0];
			var colors = pm.getElementsByClassName("colors")[0];
			
	var share = pm.getElementsByClassName("share")[0];
		//var friends = pm.getElementsByClassName("friend");
		//friendId, remove, give is Child.
			
		var add = pm.getElementsByClassName("add")[0];
			var friendIn = pm.getElementsByClassName("friend-in")[0];
			
	var del = pm.getElementsByClassName("delete")[0];
		var undo = pm.getElementsByClassName("undo")[0];
		var ignore = pm.getElementsByClassName("ignore")[0];
	
	function pmReset() {
		pm.style.display = "none";
		
		pm.style.width = "40px";
		pm.style.height = "120px";
		
		edit.style.display = "block";
			name.style.display = "none";
				nameIn.style.display = "none";
				nameIn.children[0].value = "";
			color.style.display = "none";
				colors.style.display = "none";
				colors.children[colors.children.length-1].children[0].value = "";
				
		share.style.display = "block";
			var friends = pm.getElementsByClassName("friend");
			while(friends.length > 0) {
				pm.removeChild(friends[0]);
				friends = pm.getElementsByClassName("friend");
			}
			
			add.style.display = "none";
				friendIn.style.display = "none";
				friendIn.children[0].value = "";
			
		del.style.display = "block";
			undo.style.display = "none";
			ignore.style.display = "none";
	}
	
	function alignNotes() {
		var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
		
		var shelfWidth = shelf.offsetWidth;
		
		var scenes = document.getElementsByClassName("scene");
		var sceneWidth = stanSize * 1.4;
		var sceneHeight = stanSize * 1.6; //margin 포함
		
		var supportHeight = stanSize * (0.1 + 0.25); //height, margin-bottom
		
		var properNum = shelfWidth / sceneWidth;
		
		//한 줄에 존재할 수 있는 적절한 노트의 갯수
		properNum = Math.floor(properNum);
		
		//선반의 너비 조정
		setCssVar("shelf-support-width", properNum * sceneWidth + "px");
		
		//받침의 적절한 갯수
		var supportNum = Math.ceil((notes.length -1/*#pusher는 계수하지 않는다.*/) / properNum);
		
		var supports = document.getElementsByClassName("support");
		for(var i = supports.length - 1; i >= 0; i--) {
			shelf.removeChild(supports[i]);
		}
		
		for(var i = 0; i < supportNum; i++) {
			var newSupport = document.createElement("div");
			newSupport.setAttribute("class", "support");

			if(supportNum - 1 == i) {
				shelf.appendChild(newSupport);
			} else {
				shelf.insertBefore(newSupport, notes[properNum * (i+1)].parentElement);
			}
		}
		
		//노트의 위치 정렬
		for(var i = 0; i < scenes.length; i++) {
			var rowCnt = i % properNum;
			var calCnt = Math.floor(i / properNum);
			
			scenes[i].style.left = sceneWidth * rowCnt + stanSize * 0.2 + "px";
			scenes[i].style.top = (sceneHeight + supportHeight) * calCnt + "px";
		}
		
		//선반의 위치 정렬
		for(var i = 1; i < supports.length + 1; i++) {			
			if(i == 1)
				supports[i-1].style.top = sceneHeight + "px";
			else
				supports[i-1].style.top = sceneHeight * i + supportHeight * (i-1) + "px";
		}
	}
	
	function findAncestor (el, cls) {
	    while ((el = el.parentElement) && !el.classList.contains(cls));
	    return el;
	}

	shelf.oncontextmenu = function(e) {
		e.preventDefault();
	}
	
	//note들에 event를 할당
	for(var i = 0; i < notes.length; i++) {
		notes[i].parentElement.onmouseenter = function(e) {
			var note = this.children[1];
			
			note.setAttribute("class", "note show-right");
			
			note.previousElementSibling.style.setProperty("--note-shadow-width", Number(getCssVar("note-standard-size").split("px")[0]) * 0.15 + "px");
			note.previousElementSibling.style.setProperty("--note-shadow-height", Number(getCssVar("note-standard-size").split("px")[0]) * 1.5 + "px");
		}
		notes[i].parentElement.onmouseleave = function() {
			var note = this.children[1];
			
			note.setAttribute("class", "note show-front");
			note.previousElementSibling.style.setProperty("--note-shadow-width", Number(getCssVar("note-standard-size").split("px")[0]) + "px");
			note.previousElementSibling.style.setProperty("--note-shadow-height", Number(getCssVar("note-standard-size").split("px")[0]) * 1.5 + "px");
		}
		if(i !== 0) {
			notes[i].oncontextmenu = function(e) {
				e.preventDefault();
				pmReset();
				
				triggerEvent(this.parentElement, "mouseleave");
				
				setTimeout(function() {
					pm.style.left = e.clientX;
					pm.style.top = e.clientY;
					
					pm.style.display = "block";					
				}, 50);
				
				var note = this;
				
				var meta = note.nextElementSibling;
				var noteId = meta.getElementsByClassName("id")[0].innerText.trim();
				var noteName = meta.getElementsByClassName("name")[0].innerText.trim();
				var noteIdx = Number(meta.getElementsByClassName("idx")[0].innerText.trim());
				var noteColor = meta.getElementsByClassName("color")[0].innerText.trim();
				
				nameIn.children[0].onkeydown = function(e) {
					if(e.keyCode == 13) {
						var noteName = this.value;
						//note.getElementsByClassName("name")[0].innerText = noteName;
						
						if(noteName != "")
							ajax({url:"/note/edit", 
								method:"post", 
								param:[
									       {name:"noteId", value:noteId},
									       {name:"noteName", value:noteName},
									       {name:"noteIdx", value:noteIdx},
									       {name:"noteColor", value:noteColor}
								       ], 
								success:function() {
								setTimeout(function() {
										//reForm.children[0].click();	
										note.getElementsByClassName("name")[0].innerText = noteName;
										pmReset();
									}, 500);
								}
							});
					}
				}
				
				friendIn.children[0].onkeydown = function(e) {
					if(e.keyCode == 13) {
						var friendId = this.value;
						
						if(friendId != "")
							ajax({url:"/note/share", 
								method:"post", 
								param:[
									       {name:"friendId", value:friendId},
									       {name:"noteId", value:noteId}
								       ], 
								success:function(result) {
									pmReset();
									
									if(!result)
										alert("존재하지 않거나, 중복된 사용자 입니다.");
								}
							});
					}
				}
				
				share.onclick = function(e) {					
					ajax({
						url:"/note/userNote/get",
						method:"post",
						param:[{name:"noteId", value:noteId}],
						success:function(response) {
							var isOwner = false;
							var ownerId = "";
							
							for(var j = 0; j < response.length; j++) {
								
								//create friend Element
								var friend = document.createElement("div");
								friend.setAttribute("class", "friend");
								friend.innerHTML = "";
								friend.innerHTML += "<div class=\"friend-id\"><span class=\"id\">" + response[j].userId + "</span></div>"
								friend.innerHTML += "<div class=\"remove\"><img src=\"/note/img/delete.png\"></div>"
								friend.innerHTML += "<div class=\"give\"><img src=\"/note/img/give.png\"></div>"
								
								if(response[j].isOwner == 1) {
									friend.getElementsByClassName("id")[0].style.color = "white";
									if(response[j].userId == "<%= request.getAttribute("userId") %>")
										isOwner = true;
									
									ownerId = response[j].userId;
								}
								
								pm.insertBefore(friend, add);
							}
							
							friends = pm.getElementsByClassName("friend");
							
							pmInit(120, isOwner ? 40 * (friends.length + 1) : 40 * friends.length);
							
							for(var j = 0; j < friends.length; j++) {
								var friend = friends[j];
								var id = friend.getElementsByClassName("id")[0];
								
								console.log(id);
								
								friend.style.display = "block";
								friend.style.top = j * 40 + "px";
								
									var friendId = friend.getElementsByClassName("friend-id")[0];
									friendId.style.display = "block";

									if(isOwner && ownerId != id.innerText)
										friendId.onclick = function() {
											for(var k = 0; k < friends.length; k++) {
												var friend = friends[k];
												friend.style.display = "block";
												
													var friendId = friend.getElementsByClassName("friend-id")[0];
													friendId.style.display = "block";
													
													var remove = friend.getElementsByClassName("remove")[0];
													remove.style.display = "none";
													
													var give = friend.getElementsByClassName("give")[0];
													give.style.display = "none";
											}
											
											this.style.display = "none";
											this.nextElementSibling.style.display = "block";
											this.nextElementSibling.nextElementSibling.style.display = "block";
										}
									
									var remove = friend.getElementsByClassName("remove")[0];
									remove.style.display = "none";
									
									var give = friend.getElementsByClassName("give")[0];
									give.style.display = "none";
									
									remove.onclick = function() {
										ajax({
											url:"/note/userNote/delete",
											method:"post",
											param:[
											       {name:"userId", value:this.previousElementSibling.children[0].innerText},
											       {name:"noteId", value:noteId}
											],
											success:function(response) {
												pmReset();
											}
										});
									}
									
									give.onclick = function() {
										var ownerId = this.previousElementSibling.previousElementSibling.children[0].innerText;
										console.log(ownerId);
										ajax({
											url:"/note/userNote/edit",
											method:"post",
											param:[
											       {name:"userId", value:"<%= request.getAttribute("userId") %>"},
											       {name:"noteId", value:noteId},
											       {name:"isOwner", value:0}
											],
											success:function() {
												ajax({
													url:"/note/userNote/edit",
													method:"post",
													param:[
													       {name:"userId", value:ownerId},
													       {name:"noteId", value:noteId},
													       {name:"isOwner", value:1}
													],
													success:function() {
														pmReset();
													}
												});
											}
										});
										
										
									}
									
									if(j == 0) {
										friendId.style.borderRadius = "5px 5px 0px 0px";
										give.style.borderRadius = "0px 5px 0px 0px";
										remove.style.borderRadius = "5px 0px 0px 0px";
									} else if(!isOwner && j == friends.length-1) {
										friendId.style.borderRadius = "0px 0px 5px 5px";
										give.style.borderRadius = "0px 0px 5px 0px";
										remove.style.borderRadius = "0px 0px 0px 5px";
									} else {
										friendId.style.borderRadius = "0px 0px 0px 0px";
										give.style.borderRadius = "0px 0px 0px 0px";
										remove.style.borderRadius = "0px 0px 0px 0px";
									}
							}
							
							setTimeout(function() {
								var ids = pm.getElementsByClassName("id");
								for(var j = 0; j < ids.length; j++) {
									ids[j].style.opacity = "1";
								}
							}, 250);
							
							if(isOwner) {
								add.style.display = "block";
							
								add.onclick = function() {
									pmInit(120, 120);
									friendIn.style.display = "block";
									friendIn.children[0].focus();
								}
							}
						}
					});					
				}
				
				del.onmousedown = function(e) {
					if(e.which == 1 && !ondeleting) {
						var mistake = false;
						
						//ignore를 클릭할때마다 노트들의 인덱스가
						//재 정렬된다. 따라서 ignore에 대한
						//최초의 클릭인지 판별한다.
						var alreadyAligned = false;
						
						var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
						var shWidth = Number(getCssVar("note-shadow-width").split("px")[0]);
						var shHeight = Number(getCssVar("note-shadow-height").split("px")[0]);
						var scene = note.parentElement;
						
						ondeleting = true;
						
						undo.onclick = function() {
							var end = new Date();
							
							mistake = true;
							ondeleting = false;
							
							setTimeout(function() {
								for(var i = 0; i < notes.length; i++) {
									var n = notes[i];
									
									if(n.nextElementSibling != null 
											&& Number(n.nextElementSibling.getElementsByClassName("idx")[0].innerText.trim()) == noteIdx-1) {
										var nextScene = n.parentElement;
										shelf.insertBefore(scene, nextScene);
									}
								}
								
								alignNotes();

								setTimeout(function() {
									note.parentElement.style.setProperty("--note-standard-size", stanSize + "px");
									note.style.left = "0%";
									note.style.top = "0%";
									scene.style.removeProperty("--note-standard-size");
									
									setTimeout(function() {
										note.previousElementSibling.style.display = "block";
									}, 500);
									
								}, 500);
							}, 500);
							
							pmReset();
						}
						
						ignore.onclick = function() {
							//기본 삭제 ajax를 중단
							mistake = true;
							
							if(!alreadyAligned) {
								ajax({url:"/note/delete", 
									method:"post", 
									param:[
									       		{name:"userId", value:"<%= request.getAttribute("userId") %>"},
										   		{name:"noteId", value:noteId},
										   		{name:"noteIdx", value:noteIdx}
									       ], 
									success:function() {
										//reForm.children[0].click();
											var scenes = document.getElementsByClassName("scene");
		
											for(var s = 0; s < scenes.length; s++) {
												if(s != 0 && s != scenes.length-1) {//mock과 pusher 패스
													var elIdx = scenes[s].getElementsByClassName("idx")[0];
													var idx = Number(elIdx.innerText.trim());
													if(idx > noteIdx)
														elIdx.innerText = idx-1;
												}
											}
										
										setTimeout(function() {
											triggerEvent(window,"resize");											
											shelf.removeChild(scene);
											pmReset();
											
											ondeleting = false;
											alreadyAligned = false;
										},500);
									},
									fail:function() {
										ondeleting = false;
										alreadyAligned = false;
									}
								});
								
								alreadyAligned = true;
							}
						}
						
						note.previousElementSibling.style.display = "none";
						note.parentElement.style.setProperty("--note-standard-size", "0px");
						note.style.left = stanSize / 2 + "px";
						note.style.top = stanSize * 1.5 / 2 + "px";
						
						setTimeout(function() {
							shelf.appendChild(scene);
							shelf.appendChild(pusher);
							alignNotes();
						}, 500);
						
						setTimeout(function() {
							if(!mistake)
								ajax({url:"/note/delete", 
									method:"post", 
									param:[
									       		{name:"userId", value:"<%= request.getAttribute("userId") %>"},
										   		{name:"noteId", value:noteId},
										   		{name:"noteIdx", value:noteIdx}
									       ], 
									success:function() {
										//reForm.children[0].click();
										var scenes = document.getElementsByClassName("scene");

										for(var s = 0; s < scenes.length; s++) {
											if(s != 0 && s != scenes.length-1) {//mock과 pusher 패스
												var elIdx = scenes[s].getElementsByClassName("idx")[0];
												var idx = Number(elIdx.innerText.trim());
												if(idx > noteIdx)
													elIdx.innerText = idx-1;
											}
										}
										
										setTimeout(function() {
											triggerEvent(window,"resize");											
											shelf.removeChild(scene);
											pmReset();
											
											ondeleting = false;
										},500);
									}
								});
							
							mistake = false;
						}, 2000);
					}
				}
				
				var optColors = colors.children;
				for(var j = 0; j < optColors.length; j++) {
					if(j != optColors.length-1)
						optColors[j].onclick = function() {
							var noteColor = getStyle(this, "background-color");

							//note.parentElement.style.setProperty("--note-color", noteColor);
							if(noteColor != "")
								ajax({url:"/note/edit", 
									method:"post", 
									param:[
										       {name:"noteId", value:noteId},
										       {name:"noteName", value:noteName},
										       {name:"noteIdx", value:noteIdx},
										       {name:"noteColor", value:noteColor}
									       ], 
									success:function() {
										setTimeout(function() {
											//reForm.children[0].click();		
											note.parentElement.style.setProperty("--note-color", noteColor);
											pmReset();
										}, 500);
									}
								});
						}
					else //사용자 입력 색상
						optColors[j].children[0].onkeydown = function(e) {
							if(e.keyCode == 13) {
								var noteColor = this.value;
								var exit = false;
								
								//db의 maxLength 는 24이다.
								if(noteColor.length <= 24) {
									if(noteColor.substring(0, 4) != "rgba")
										if(noteColor.split(",").length == 4)
											noteColor = "rgba(" + noteColor + ")";
										else if(noteColor.split(",").length == 3)
											noteColor = "rgba(" + noteColor + ", 1)";
										else if(noteColor.split(" ").length == 4)
											noteColor =  "rgba(" + noteColor.split(" ")[0] + ", " + noteColor.split(" ")[1] + ", " + noteColor.split(" ")[2] + ", " + noteColor.split(" ")[3] + ")";
										else if(noteColor.split(" ").length == 3)
											noteColor =  "rgba(" + noteColor.split(" ")[0] + ", " + noteColor.split(" ")[1] + ", " + noteColor.split(" ")[2] + ", 1)";
										else
											exit = true;
									
									if(!exit) {
										//note.parentElement.style.setProperty("--note-color", noteColor);
										
										if(noteColor != "")
											ajax({url:"/note/edit", 
												method:"post", 
												param:[
													       {name:"noteId", value:noteId},
													       {name:"noteName", value:noteName},
													       {name:"noteIdx", value:noteIdx},
													       {name:"noteColor", value:noteColor}
												       ], 
												success:function() {
												setTimeout(function() {
														//reForm.children[0].click();	
														note.parentElement.style.setProperty("--note-color", noteColor);
														pmReset();
													}, 500);
												}
											});
									}
								}
							}
						}
				}
				
				shelf.onclick = function(e) {
					pmReset();
				}
			}
			
			notes[i].parentElement.onmousedown = function(e) {
				var sel = window.getSelection();
				sel.removeAllRanges();
				
				var scene = this;
				var note = scene.getElementsByClassName("note")[0];
				var shadow = scene.getElementsByClassName("shadow")[0];
				
				var isPicked;
				var isMovingOut;
				
				if(notes.length > 3)
					isPicked = true;
				
				scene.style.zIndex = "10";
									
				window.onmousemove = function(ev) {
					var sel = window.getSelection();
					sel.removeAllRanges();
					
					var left = scene.getBoundingClientRect().left;
					var top = scene.getBoundingClientRect().top;
					var right = scene.getBoundingClientRect().right;
					var bottom = scene.getBoundingClientRect().bottom;
					
					var x = ev.clientX;
					var y = ev.clientY;
					
					isMovingOut = true;
					if(left < x && x < right)
						if(top < y && y < bottom)
							isMovingOut = false;
					
					if(isPicked && isMovingOut) {
						scene.style.left = x - window.innerWidth / 10 + "px";
						scene.style.top = y - window.innerHeight / 10 + "px";
						
						scene.style.transitionDuration = "0s";
					}
				}
				
				window.onmouseup = function(ev) {
					if(isPicked && isMovingOut) {
						scene.style.transitionDuration = "0.5s";
						
						//-----------------------------//
						var ex = ev.clientX;
						var ey = ev.clientY;
						
						//c : closest 
						//cc : closest coordinate
						//1 : most
						//2 : second
						var log = {c1:"", c2:"", c1c:999999999999, c2c:9999999999999};
						for(var j = 0; j < notes.length; j++) {
							if(notes[j] != note 
									&& j != notes.length-1) {//pusher는 거른다.
								//노트의 크기
								var w = notes[j].getBoundingClientRect().right - notes[j].getBoundingClientRect().left;
								var h = notes[j].getBoundingClientRect().bottom - notes[j].getBoundingClientRect().top;
								
								//노트의 중심 좌표
								var x = notes[j].getBoundingClientRect().left + w / 2;
								var y = notes[j].getBoundingClientRect().top + h / 2;
								
								var l = Math.cbrt(Math.pow((ex - x), 2) + Math.pow((ey - y), 2));
								
								if(log.c1c > l) {
									log.c2 = log.c1;
									log.c1 = notes[j];
									
									log.c2c = log.c1c;
									log.c1c = l;
								} else if(log.c2c > l) {
									log.c2 = notes[j];
									
									log.c2c = l;
								}
							}
						}
						
						
						var isLast = false;
						
						//between length
						var bl = Math.abs(log.c1.getBoundingClientRect().right - log.c2.getBoundingClientRect().right);
						if(log.c1 == notes[notes.length-1 -1/*#pusher는 계수하지 않는다.*/] && log.c2c > log.c1c)
							isLast = true;

						//origin index
						var oi = Number(note.nextElementSibling.getElementsByClassName("idx")[0].innerText.trim());

						var c1i, c2i;
						if(!log.c1.children[0].classList.contains("mock"))
							c1i = Number(log.c1.nextElementSibling.getElementsByClassName("idx")[0].innerText.trim());
						else
							c1i = notes.length-1-1;
						
						if(!log.c2.children[0].classList.contains("mock"))
							c2i = Number(log.c2.nextElementSibling.getElementsByClassName("idx")[0].innerText.trim());
						else
							c2i = notes.length-1-1;
						
						//change index
						var ci;
						
						if(isLast) {
							shelf.appendChild(scene);
							ci = c1i;
						} else if(c1i < c2i) {
							shelf.insertBefore(scene, log.c1.parentElement);
							ci = c1i;
						} else {
							shelf.insertBefore(scene, log.c2.parentElement);
							ci = c2i;
						}
						
						//#pusher는 항상 마지막에 와야한다.
						shelf.appendChild(pusher);
						//-----------------------------//
					
						var noteId = Number(note.nextElementSibling.getElementsByClassName("id")[0].innerText.trim());

						ajax({url:"/note/reAlign", 
							method:"post", 
							param:[
								       {name:"originIdx", value:oi}, 
								       {name:"changeIdx", value:ci},
								       {name:"noteId", value:noteId},
								       {name:"userId", value:"<%= request.getAttribute("userId") %>"},
								       {name:"isLast", value:isLast}
							       ], 
							success:function() {
								setTimeout(function() {
									//reForm.children[0].click();	
									var scenes = document.getElementsByClassName("scene");
									for(var s = 1; s < scenes.length-1; s++) {
										var sId = scenes[s].getElementsByClassName("id")[0];
										var sIdx = scenes[s].getElementsByClassName("idx")[0];
										var id = Number(sId.innerText.trim());
										var idx = Number(sIdx.innerText.trim());
										
										if(id != noteId) {
											if(isLast) {
												if(ci <= idx && idx <= oi-1)
													sIdx.innerText = idx+1;
											} else if(oi < ci) {
												if(oi+1 <= idx && idx <= ci)
													sIdx.innerText = idx-1;
											} else if(oi > ci) {
												if(ci+1 <= idx && idx <= oi-1)
													sIdx.innerText = idx+1;
											}
										} else {
											sIdx.innerText = oi < ci || isLast ? ci : ci+1;
										}
									}
									
									isLast = false;

									window.onmouseup = undefined;
									window.onmousemove = undefined;
									
									triggerEvent(window, "resize");
									
									scene.style.transitionDuration = "0.5s";
									scene.style.removeProperty("z-index");
								}, 500);
							},
							fail:function() {
								isLast = false;
							}
						});
						
						window.onmouseup = undefined;
						window.onmousemove = undefined;
						
						triggerEvent(window, "resize");
						
						scene.style.transitionDuration = "0.5s";
						scene.style.removeProperty("z-index");
						
						isPicked = false;
					} else {
						window.onmouseup = undefined;
						window.onmousemove = undefined;
						
						triggerEvent(window, "resize");
						
						scene.style.transitionDuration = "0.5s";
						scene.style.removeProperty("z-index");
					}
				}
			}
			
			notes[i].getElementsByClassName("right")[0].onmousedown = function(e) {
				if(e.which == 1) {
					var meta = this.parentElement.nextElementSibling;
					var note = this.parentElement;
					var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
					
					var x = note.getBoundingClientRect().left;
					var y = note.getBoundingClientRect().top;
					
					iframe.style.width = stanSize * 0.15 / 4 * 5 + "px";
					iframe.style.height = stanSize * 1.5 / 3 * 10 + "px";
					
					iframe.style.top = y + stanSize * 0.05 - stanSize * 1.5 / 6 * 7 + "px";
					iframe.style.left = x + stanSize * 0.025 - stanSize * 0.15 / 8 + "px";
				
					
					noteForm.children[0].setAttribute("value", meta.getElementsByClassName("id")[0].innerText);
					noteForm.children[1].setAttribute("value", meta.getElementsByClassName("idx")[0].innerText);
					noteForm.children[2].setAttribute("value", meta.getElementsByClassName("name")[0].innerText);
					noteForm.children[3].setAttribute("value", meta.getElementsByClassName("color")[0].innerText);
					noteForm.children[4].click();
				}
			}
			
			notes[i].getElementsByClassName("right")[0].onmouseup = function(e) {
				if(e.which == 1) {
					var note = this.parentElement;
					iframe.style.display = "block";
					
					setTimeout(function() {
						iframe.style.left = "0px";
						iframe.style.top = "0px";
						iframe.style.width = "100%";
						iframe.style.height = "100%";
						
						triggerEvent(note.parentElement, "mouseenter");
					}, 50);
				}
			}
		}
	}

	window.onmessage = function(e) {
		var note = notes[notes.length -1 -1 - Number(e.data)];
		var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
		
		if(note.getAttribute("class") == "note show-right") {
			var x = note.getBoundingClientRect().left;
			var y = note.getBoundingClientRect().top;
			
			iframe.style.width = stanSize * 0.15 / 4 * 5 + "px";
			iframe.style.height = stanSize * 1.5 / 3 * 10 + "px";
			
			iframe.style.top = y + stanSize * 0.05 - stanSize * 1.5 / 6 * 7 + "px";
			iframe.style.left = x + stanSize * 0.025 - stanSize * 0.15 / 8 + "px";
		
			setTimeout(function() {
				iframe.style.display = "none";
				
				setTimeout(function() {
					triggerEvent(note.parentElement, "mouseleave");				
				}, 50);
			}, 500);
		} else {
			triggerEvent(note.parentElement, "mouseenter");
		
			setTimeout(function() {
				var x = note.getBoundingClientRect().left;
				var y = note.getBoundingClientRect().top;
				
				iframe.style.width = stanSize * 0.15 / 4 * 5 + "px";
				iframe.style.height = stanSize * 1.5 / 3 * 10 + "px";
				
				iframe.style.top = y + stanSize * 0.05 - stanSize * 1.5 / 6 * 7 + "px";
				iframe.style.left = x + stanSize * 0.025 - stanSize * 0.15 / 8 + "px";
			
				setTimeout(function() {
					iframe.style.display = "none";
					
					setTimeout(function() {
						triggerEvent(note.parentElement, "mouseleave");				
					}, 50);
				}, 500);
			}, 500);
		}
	}
	
	if(window.innerWidth < 768) {
		setCssVar("note-standard-size", "50px");
	} else {
		setCssVar("note-standard-size", "100px");
	}
	
	for(var i = 0; i < notes.length; i++) {
		notes[i].previousElementSibling.style.setProperty("--note-shadow-width", Number(getCssVar("note-standard-size").split("px")[0]) + "px");
		notes[i].previousElementSibling.style.setProperty("--note-shadow-height", Number(getCssVar("note-standard-size").split("px")[0]) * 1.5 + "px");
	}
	
	//mock note's scene
	shelf.children[0].onclick = function(e) {
		if(!ondeleting) {
			var color = "rgb(" + Math.floor(Math.random()*1000)%256 + "," + Math.floor(Math.random()*1000)%256 + "," + Math.floor(Math.random()*1000)%256 + ")";
			
			this.removeAttribute("style");
			removeClass(this, "mock");
			this.setAttribute("style", "--note-color:" + color);
			
			this.children[0].style.setProperty("--note-shadow-width", Number(getCssVar("note-standard-size").split("px")[0]) + "px");
			this.children[0].style.setProperty("--note-shadow-height", Number(getCssVar("note-standard-size").split("px")[0]) * 1.5 + "px");
			this.children[1].setAttribute("class", "note show-front");
			
			pusher.style.display = "inline-block";
			shelf.insertBefore(pusher, this);
			triggerEvent(window, "resize");
			
			setTimeout(function() {
				ajax({url:"/note/add", 
					method:"post", 
					param:[
						       {name:"idx", value:notes.length - 1-1}, 
						       {name:"userId", value:"<%= request.getAttribute("userId") %>"},
						       {name:"color", value:color}
					       ], 
					success:function() {
						reForm.children[0].click();
					}
				});
			}, 500);
		}
	}
	
	alignNotes();
	
	setTimeout(function() {
		setCssVar("transition-duration", "0.5s");		
	}, 50);
	
	window.onresize = function() {
		if(window.innerWidth < 768) {
			setCssVar("note-standard-size", "50px");
		} else {
			setCssVar("note-standard-size", "100px");
		}
		
		var stanSize = Number(getCssVar("note-standard-size").split("px")[0]);
		for(var i = 0; i < notes.length; i++) {
			if(notes[i].classList.contains("show-front")) {
				notes[i].previousElementSibling.style.setProperty("--note-shadow-width", stanSize + "px");
				notes[i].previousElementSibling.style.setProperty("--note-shadow-height", stanSize * 1.5 + "px");
			} else {
				notes[i].previousElementSibling.style.setProperty("--note-shadow-width", stanSize * 0.15 + "px");
				notes[i].previousElementSibling.style.setProperty("--note-shadow-height", stanSize * 1.5 + "px");
			}
		}
		
		alignNotes();
	}
	
	function pmInit(width, height) {
		pm.style.display = "block";
		
		if(width != undefined)
			pm.style.width = width + "px";
		if(height != undefined)
			pm.style.height = height + "px";
		
		edit.style.display = "none";
			name.style.display = "none";
				nameIn.style.display = "none";
			color.style.display = "none";
				colors.style.display = "none";
				
		share.style.display = "none";
			var friends = pm.getElementsByClassName("friend");
			for(var i = 0; i < friends.length; i++) {
				var friend = friends[i];
				friend.style.display = "none";
				
					var friendId = friend.getElementsByClassName("friend-id")[0];
					friendId.style.display = "none";
					
					var remove = friend.getElementsByClassName("remove")[0];
					remove.style.display = "none";
					
					var give = friend.getElementsByClassName("give")[0];
					give.style.display = "none";
			}
			
			add.style.display = "none";
				friendIn.style.display = "none";
			
		del.style.display = "none";
			undo.style.display = "none";
			ignore.style.display = "none";
	}
	
	/*note 우클릭시 나오는 popup menu*/ 
	edit.onclick = function() {
		/*menu summary*/
		pmInit(40, 120);
		
		name.style.display = "block";
		color.style.display = "block";
		
		/*sub menu's handler*/
		name.onclick = function() {			
			pmInit(120, 120);
			
			pm.style.display = "block";
			nameIn.style.display = "block";
			nameIn.children[0].focus();
		}
		
		color.onclick = function() {
			pmInit(120, 120);
			
			pm.style.display = "block";
			colors.style.display = "block";
			colors.children[colors.children.length-1].children[0].focus();
		}
	}

	//share는 노트별로 메뉴가 달라지므로 note의 oncontextmenu의 핸들러에서 다룬다.
	
	del.onclick = function() {
		pmInit(40, 120);
		
		undo.style.display = "block";
		ignore.style.display = "block";
	}
	///////////////////////////////////계정 정보 수정///////////////////////////////////
	
	// 계정 -> 계정수정
 	$("#icon").bind("click", function(){
		// 창 조절
		$(".demo").css('top','calc(50% - 26.5rem)');
		$(".demo").css('left','calc(50% - 20rem)');
		$(".demo").css('width','40rem');
		$(".demo").css('height','30rem');
		$(".tomain").css('display','block');
		// 내용변경
		$('#icon').css('display','none');
		$(".myUser").css('opacity','1');
		$("#deleteuser").css('opacity','1');
		$("#logout").css('opacity','1');
	});
	
 // 계정정보 -> 이름수정
 	$("#nameUser").bind("click",function(){
 		$(".myUser").css('opacity','0');
 		$("#deleteuser").css('opacity','0');
 		$("#logout").css('opacity','0');	
 		
 		setTimeout(function() {$(".myUser").css('display','none');}, 700);
 		setTimeout(function() {$("#deleteuser").css('display','none');}, 700);
 		setTimeout(function() {$("#logout").css('display','none');}, 700);
 		
 		setTimeout(function() {$("#nameColor").css('display','block');}, 700);
 		setTimeout(function() {$("#nameError").css('display','block');}, 700);
 		setTimeout(function() {$("#back").css('display','block');}, 700);
 		setTimeout(function() {$("#next").css('display','block');}, 700);
 		
 		setTimeout(function() {$("#nameColor").css('opacity','1');}, 800);
 		setTimeout(function() {$("#nameError").css('opacity','1');}, 800);
 		setTimeout(function() {$("#back").css('opacity','1');}, 800);
 		setTimeout(function() {$("#next").css('opacity','1');}, 800);
 	});

 	// 계정정보 -> 비밀번호수정
 	$("#pwUser").bind("click",function(){
 		$(".myUser").css('opacity','0');
 		$("#deleteuser").css('opacity','0');
 		$("#logout").css('opacity','0');	
 		
 		setTimeout(function() {$(".myUser").css('display','none');}, 700);
 		setTimeout(function() {$("#deleteuser").css('display','none');}, 700);
 		setTimeout(function() {$("#logout").css('display','none');}, 700);
 		
 		setTimeout(function() {$("#pwColor").css('display','block');}, 700);
 		setTimeout(function() {$("#pwError").css('display','block');}, 700);
 		setTimeout(function() {$("#pwCheck").css('display','block');}, 700);
 		setTimeout(function() {$("#pwckError").css('display','block');}, 700);
 		setTimeout(function() {$("#back").css('display','block');}, 700);
 		setTimeout(function() {$("#next").css('display','block');}, 700);
 		
 		setTimeout(function() {$("#pwColor").css('opacity','1');}, 800);
 		setTimeout(function() {$("#pwError").css('opacity','1');}, 800);
 		setTimeout(function() {$("#pwCheck").css('opacity','1');}, 800);
 		setTimeout(function() {$("#pwckError").css('opacity','1');}, 800);
 		setTimeout(function() {$("#back").css('opacity','1');}, 800);
 		setTimeout(function() {$("#next").css('opacity','1');}, 800);
 	});

 	// 계정정보 -> 이메일수정
 	$("#emailUser").bind("click",function(){
 		$(".myUser").css('opacity','0');
 		$("#deleteuser").css('opacity','0');
 		$("#logout").css('opacity','0');
 		
 		setTimeout(function() {$(".myUser").css('display','none');}, 700);
 		setTimeout(function() {$("#deleteuser").css('display','none');}, 700);
 		setTimeout(function() {$("#logout").css('display','none');}, 700);
 		
 		setTimeout(function() {$("#emailColor").css('display','block');}, 700);
 		setTimeout(function() {$("#emailError").css('display','block');}, 700);
 		setTimeout(function() {$("#back").css('display','block');}, 700);
 		setTimeout(function() {$("#next").css('display','block');}, 700);
 		
 		setTimeout(function() {$("#emailColor").css('opacity','1');}, 800);
 		setTimeout(function() {$("#emailError").css('opacity','1');}, 800);
 		setTimeout(function() {$("#back").css('opacity','1');}, 800);
 		setTimeout(function() {$("#next").css('opacity','1');}, 800);
 	});
 	
 	// 계정정보 -> 계정삭제
 	$("#deleteuser").bind("click", function(){
 		$(".myUser").css('opacity','0');
 		$("#deleteuser").css('opacity','0');
 		$("#logout").css('opacity','0');
 		
 		setTimeout(function() {$(".myUser").css('display','none');}, 700);
 		setTimeout(function() {$("#deleteuser").css('display','none');}, 700);
 		setTimeout(function() {$("#logout").css('display','none');}, 700);

 		setTimeout(function() {$("#delMsg1").css('display','block');}, 700);
 		setTimeout(function() {$("#delMsg2").css('display','block');}, 700);
 		setTimeout(function() {$("#delMsg3").css('display','block');}, 700);
 		setTimeout(function() {$("#back").css('display','block');}, 700);
 		setTimeout(function() {$("#confirming").css('display','block');}, 700);
 		
 		setTimeout(function() {$("#delMsg1").css('opacity','1');}, 800);
 		setTimeout(function() {$("#delMsg2").css('opacity','1');}, 800);
 		setTimeout(function() {$("#delMsg3").css('opacity','1');}, 800);
 		setTimeout(function() {$("#back").css('opacity','1');}, 800);
 		setTimeout(function() {$("#confirming").css('opacity','1');}, 800);
	});

 	// 정보수정 -> 계정정보
 	$("#back").bind("click",function(){
 		// 오류상황 해제
 		$('#nameColor input + span').css('color','#0077FF'); 
		$('#nameColor .border').css('background','#0077FF');  
		$('#nameColor input').css('border-bottom','2px solid #0077FF'); 
		$("#nameError").text("");
		
		$('#pwColor input + span').css('color','#0077FF'); 
		$('#pwColor .border').css('background','#0077FF');
		$('#pwColor input').css('border-bottom','2px solid #0077FF');
		$("#pwError").text("");	
		$('#pwCheck input + span').css('color','#0077FF'); 
		$('#pwCheck .border').css('background','#0077FF');
		$('#pwCheck input').css('border-bottom','2px solid #0077FF');
		$("#pwckError").text("");
 		
 		$('#emailColor input + span').css('color','#0077FF'); 
		$('#emailColor .border').css('background','#0077FF');  
		$('#emailColor input').css('border-bottom','2px solid #0077FF'); 
		$("#emailError").text("");
		
		// 창 변화
 		$("#nameColor").css('opacity','0');	
 		$("#nameError").css('opacity','0');
 		$("#pwColor").css('opacity','0');
 		$("#pwError").css('opacity','0');
 		$("#pwCheck").css('opacity','0');
 		$("#pwckError").css('opacity','0');
 		$("#emailCheck").css('opacity','0');
 		$("#emailError").css('opacity','0');
 		$("#delMsg1").css('opacity','0');
 		$("#delMsg2").css('opacity','0');
 		$("#delMsg3").css('opacity','0');
 		$("#back").css('opacity','0');
 		$("#next").css('opacity','0');
 		$("#confirming").css('opacity','0');
 		
 		setTimeout(function() {$("#nameColor").css('display','none');}, 700);
 		setTimeout(function() {$("#nameError").css('display','none');}, 700);
 		setTimeout(function() {$("#pwColor").css('display','none');}, 700);
 		setTimeout(function() {$("#pwError").css('display','none');}, 700);
 		setTimeout(function() {$("#pwCheck").css('display','none');}, 700);
 		setTimeout(function() {$("#pwckError").css('display','none');}, 700);
 		setTimeout(function() {$("#emailColor").css('display','none');}, 700);
 		setTimeout(function() {$("#emailError").css('display','none');}, 700);
 		setTimeout(function() {$("#delMsg1").css('display','none');}, 700);
 		setTimeout(function() {$("#delMsg2").css('display','none');}, 700);
 		setTimeout(function() {$("#delMsg3").css('display','none');}, 700);
 		setTimeout(function() {$("#back").css('display','none');}, 700);
 		setTimeout(function() {$("#next").css('display','none');}, 700);
 		setTimeout(function() {$("#confirming").css('display','none');}, 700);
 		
 		setTimeout(function() {$(".myUser").css('display','block');}, 700);
 		setTimeout(function() {$("#deleteuser").css('display','block');}, 700);
 		setTimeout(function() {$("#logout").css('display','block');}, 700);

 		setTimeout(function() {$(".myUser").css('opacity','1');}, 800);
 		setTimeout(function() {$("#deleteuser").css('opacity','1');}, 800);
 		setTimeout(function() {$("#logout").css('opacity','1');}, 800);
 	});
		
	var $inputName = $("input[name='userName']"); //이름 입력창
	var $inputPw = $("input[name='userPw']");     //비밀번호 입력창
	var $checkPw = $("input[name='checkPw']");    //비밀번호 확인 입력창
	var $inputEmail = $("input[name='userEmail']");    //이메일 입력창 */
	
	// 입력창에서 enter 누르면 확인 버튼 클릭.
	$inputName.bind("keydown", function(event){if(event.which == 13){$('#next').click();}});
	// 입력창에서 enter 누르면 비번확인으로 이동.
	$inputPw.bind("keydown", function(event){
		if(event.which == 13){
			if($inputPw.val() != ""){
				$('#pwColor input + span').css('color','#0077FF'); 
				$('#pwColor .border').css('background','#0077FF');
				$('#pwColor input').css('border-bottom','2px solid #0077FF');
				$("#pwError").text("");	
				$checkPw.focus();
			}else{
				$('#pwColor input + span').css('color','#a30404');  
				$('#pwColor .border').css('background','#a30404');  
				$('#pwColor input').css('border-bottom','2px solid #a30404'); 
				$("#pwError").text("비밀번호가 입력되지않았습니다");	
			}	
		}
	}); 
	// 입력창에서 enter 누르면 확인 버튼 클릭.
 	$checkPw.bind("keydown", function(event){
 		if(event.which == 13){	
 			if($checkPw.val() != ""){
 				$('#pwCheck input + span').css('color','#0077FF'); 
 				$('#pwCheck .border').css('background','#0077FF');
 				$('#pwCheck input').css('border-bottom','2px solid #0077FF');
 				$("#pwckError").text("");
 				$('#next').click();
 			}else{
 				$('#pwCheck input + span').css('color','#a30404');  
 				$('#pwCheck .border').css('background','#a30404');  
 				$('#pwCheck input').css('border-bottom','2px solid #a30404'); 
 				$("#pwckError").text("비밀번호 확인이 입력되지않았습니다");
 			}
		}
	});
	// 입력창에서 enter 누르면 확인 버튼 클릭.
	$inputEmail.bind("keydown", function(event){
		if(event.which == 13){
			var exptext = /^[A-Za-z0-9_\.\-]+@[A-Za-z0-9\-]+\.[A-Za-z0-9\-]+/;
			if($inputEmail.val() == ""){
				$('#emailColor input + span').css('color','#a30404');  
				$('#emailColor .border').css('background','#a30404'); 
				$('#emailColor input').css('border-bottom','2px solid #a30404'); 
				$("#emailError").text("이메일이 입력되지않았습니다");
			}else if(exptext.test($inputEmail.val())==false){
				$('#emailColor input + span').css('color','#a30404');  
				$('#emailColor .border').css('background','#a30404'); 
				$('#emailColor input').css('border-bottom','2px solid #a30404'); 
				$("#emailError").text("이메일형식이 아닙니다.");
			}else{
				$('#next').click();
			}
		}
	});
	
	$("#next").bind("click", function(){
		//이름변경
		if($inputName.val() != ""){
			$.ajax({
				method: "post",
				url: "nameChange",
				data:{
					userName:$inputName.val()
				},
				success:function(corUser){
					$('#nameColor input + span').css('color','#0077FF'); 
					$('#nameColor .border').css('background','#0077FF');  
					$('#nameColor input').css('border-bottom','2px solid #0077FF'); 
					$("#nameError").text("");
					
					// 계정 정보에 이름 바뀐 이름으로 변화, button id=nameUser 안에 있는 span 내용 지우고 바뀐이름으로
					$("#nameUser span").text(corUser.userName);
					
					// 계정 정보 로 이동
			 		$("#nameColor").css('opacity','0');
			 		$("#nameError").css('opacity','0');
			 		$("#back").css('opacity','0');
			 		$("#next").css('opacity','0');
			 		setTimeout(function() {$("#nameColor").css('display','none');}, 700);
			 		setTimeout(function() {$("#nameError").css('display','none');}, 700);
			 		setTimeout(function() {$("#back").css('display','none');}, 700);
			 		setTimeout(function() {$("#next").css('display','none');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('display','block');}, 700);
			 		setTimeout(function() {$("#deleteuser").css('display','block');}, 700);
			 		setTimeout(function() {$("#logout").css('display','block');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#deleteuser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#logout").css('opacity','1');}, 800);	
				},
				error:function(){
					alert("서버 오류");
				}
			});
		}else{
			$('#nameColor input + span').css('color','#a30404'); 
			$('#nameColor .border').css('background','#a30404');  
			$('#nameColor input').css('border-bottom','2px solid #a30404'); 
			$("#nameError").text("이름이입력되지않았습니다");
		}
		
		// 비번변경
		if(($inputPw.val() != "")&&($checkPw.val() != "")&&($inputPw.val() == $checkPw.val())){
			$.ajax({
				method: "post",
				url: "pwChange",
				data:{
					userPw:$inputPw.val()
				},
				success:function(corUser){
					// 계정 정보에 이름 바뀐 이름으로 변화, button id=nameUser 안에 있는 span 내용 지우고 바뀐이름으로
					$("#pwUser span").text(corUser.userPw);
					
					// 계정 정보 로 이동
			 		$("#pwColor").css('opacity','0');
			 		$("#pwError").css('opacity','0');
			 		$("#pwCheck").css('opacity','0');
			 		$("#pwckError").css('opacity','0');
			 		$("#back").css('opacity','0');
			 		$("#next").css('opacity','0');
			 		setTimeout(function() {$("#pwColor").css('display','none');}, 700);
			 		setTimeout(function() {$("#pwError").css('display','none');}, 700);
			 		setTimeout(function() {$("#pwCheck").css('display','none');}, 700);
			 		setTimeout(function() {$("#pwckError").css('display','none');}, 700);
			 		setTimeout(function() {$("#back").css('display','none');}, 700);
			 		setTimeout(function() {$("#next").css('display','none');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('display','block');}, 700);
			 		setTimeout(function() {$("#deleteuser").css('display','block');}, 700);
			 		setTimeout(function() {$("#logout").css('display','block');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#deleteuser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#logout").css('opacity','1');}, 800);
				},
				error:function(){
					alert("서버 오류");
				}
			});
		}	
		
		//이름변경
		if($inputEmail.val() != ""){
			$.ajax({
				method: "post",
				url: "emailChange",
				data:{
					userEmail:$inputEmail.val()
				},
				success:function(corUser){
					// 계정 정보에 이름 바뀐 이름으로 변화, button id=nameUser 안에 있는 span 내용 지우고 바뀐이름으로
					$("#emailUser span").text(corUser.userEmail);
					
					// 계정 정보 로 이동
			 		$("#emailColor").css('opacity','0');
			 		$("#emailError").css('opacity','0');
			 		$("#back").css('opacity','0');
			 		$("#next").css('opacity','0');
			 		
			 		setTimeout(function() {$("#emailColor").css('display','none');}, 700);
			 		setTimeout(function() {$("#emailError").css('display','none');}, 700);
			 		setTimeout(function() {$("#back").css('display','none');}, 700);
			 		setTimeout(function() {$("#next").css('display','none');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('display','block');}, 700);
			 		setTimeout(function() {$("#deleteuser").css('display','block');}, 700);
			 		setTimeout(function() {$("#logout").css('display','block');}, 700);
			 		
			 		setTimeout(function() {$(".myUser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#deleteuser").css('opacity','1');}, 800);
			 		setTimeout(function() {$("#logout").css('opacity','1');}, 800);		
				},
				error:function(){
					alert("서버 오류");
				}
			});
		}
	});
	// 계정삭제
 	$("#confirming").bind("click", function(){
 		if($("#delMsg3 input:checked").size()){
 			setTimeout(function() {window.location.href="http://localhost/note/delUser";}, 700);
 		}
	});
		
	// 로그아웃
 	$("#logout").bind("click", function(){
		setTimeout(function() {window.location.href="http://localhost/note/logout";}, 700);
	});
	
	$(".tomain").bind("click",function(){
		// 창 조절
		$(".demo").css('top','2%');
		$(".demo").css('left','93%');
		$(".demo").css('width','5rem');
		$(".demo").css('height','5rem');
		
		$("#back").trigger("click");
		
		setTimeout(function() {$('#icon').css('display','block');}, 700);
		setTimeout(function() {$(".tomain").css('display','none');}, 700);
	});
}
</script>
<style>
@import "/note/css/note.css";
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
	    background: #D8D8D8;
	}
	.scene .shadow {
		position:absolute;
		
		left:calc(50% - var(--note-shadow-width) * 0.9 / 2);
		top:calc(50% - var(--note-shadow-height) * 0.9 / 2);
		
		width:calc(var(--note-shadow-width) * 0.9);
		height:calc(var(--note-shadow-height) * 0.9);
		
		border-radius:calc(var(--note-standard-size) * 0.05);
		
		box-shadow:0px calc(var(--note-shadow-height)  / 3 * 2 / 10) calc(var(--note-shadow-height)  / 3 * 2 / 5) calc(var(--note-shadow-height)  / 3 * 2 / 10) rgba(0, 0, 0, 0.5);
		
		transition-duration:var(--transition-duration);
		transition-timing-function:ease;
	}
	.scene .meta {
		display:none;
	}
	.shelf {
		position:fixed;
		
		width:80%;
		height:80%;
		
		left:10%;
		top:10%;
		
		overflow:auto;
	}
	.shelf .support {		
		position:absolute;
		
		width:var(--shelf-support-width);
		height:calc(var(--note-standard-size) / 10);
		
		left:calc(var(--note-standard-size) * 0.2);
		top:0%;
		
		margin-bottom:calc(var(--note-standard-size) * 0.25);
		
		box-shadow:0px 5px 5px 1px rgba(0, 0, 0, 0.5);
		
		transition-duration:0.5s;
	}
	.mock {
		background-color:transparent;
		border-style:inset;
		border-color:white;
		border-width:1px;
	}
	#pusher {
		display:none;
		visibility:hidden;
	}
	iframe {
		position:fixed;
		display:none;
		
		left:0px;
		top:0px;
		
		/*
		 * 오른쪽의 페이지 부분의 너비는 표준 길이 * 0.15이다.
		 */
		width:calc(var(--note-standard-size) * 0.15 * 5 / 4);
		height:calc(var(--note-standard-size) * 1.5 * 2);
		
		z-index:5;
		
		transition-duration:0.5s;
	}
	form {
		display:none;
	}
	body {
		background-color:gray;
		overflow:auto;
	}
	.popup-menu {
		position:fixed;
		display:none;
		
		width:40px;
		height:120px;
		
		left:100px;
		top:150px;
		
		z-index:3;
		
		border-radius:5px;
		
		background-color:rgba(256, 256, 256, 0.5);
		box-shadow:0px 5px 10px 1px rgba(0, 0, 0, 0.5);
		
		transition-duration:0.25s;
	}
	/*pm height 120px*/
	.popup-menu .edit,
	.popup-menu .share,
	.popup-menu .delete {
		position:absolute;
		
		width:100%;
		height:33.3%;
		
		transition-duration:0.25s;
	}
	.popup-menu .edit {border-radius:5px 5px 0px 0px;}
	.popup-menu .share {top:33.3%;}
	.popup-menu .delete {top:66.6%; border-radius:0px 0px 5px 5px;}
	
	.popup-menu .edit:hover {background-color:rgba(256, 256, 256, 0.8);}
	.popup-menu .share:hover {background-color:rgba(256, 256, 256, 0.8);}
	.popup-menu .delete:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	/*pm height 80px*/
	.popup-menu .name,
	.popup-menu .color {
		position:absolute;
		display:none;
		
		width:100%;
		height:50%;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .name-in,
	.popup-menu .friend-in {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
		
		border-radius:5px;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .name-in input,
	.popup-menu .friend-in input {
		position:absolute;
		
		width:100%;
		height:100%;
		
		text-align:center;
		
		outline:none;
		border:none;
		
		border-radius:5px;
	}
	
	.popup-menu .colors {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
		
		border-radius:5px;
	}
	.popup-menu .colors * {
		position:absolute;
		
		width:33.3%;
		height:33.3%;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .colors .a {left:0%; top:0%; border-radius:5px 0px 0px 0px; background-color:#6B5B95;}
	.popup-menu .colors .b {left:33.3%; top:0%; background-color:#006E6D;}
	.popup-menu .colors .c {left:66.6%; top:0%; border-radius:0px 5px 0px 0px; background-color:#E94B3C;}
	.popup-menu .colors .d {left:0%; top:33.3%; background-color:#DBB1CD;}
	.popup-menu .colors .e {left:33.3%; top:33.3%; background-color:#B4B7BA;}
	.popup-menu .colors .f {left:66.6%; top:33.3%; background-color:#BFD641;}
	.popup-menu .colors .color-in {
		width:100%;
		heigh:33.3%;
	
		left:0%;
		top:66.6%; 
		
		border-radius:0px 0px 5px 5px;
		
		background-color:black;
	}
	.popup-menu .colors .color-in input {
		position:absolute;
		
		width:100%;
		height:100%;
		
		left:0%;
		top:0%;
		
		text-align:center;
		
		padding:0px;
		margin:0px;
		outline:none;
		border:none;
		
		border-radius:0px 0px 5px 5px;
	}
	
	.popup-menu .colors .a:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	.popup-menu .colors .b:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	.popup-menu .colors .c:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	.popup-menu .colors .d:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	.popup-menu .colors .e:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	.popup-menu .colors .f:hover {box-shadow:inset 0px 0px 5px 1px rgba(0, 0, 0, 0.5);}
	
	.popup-menu .name {top:0%; border-radius:5px 5px 0px 0px;}
	.popup-menu .color  {top:50%; border-radius:0px 0px 5px 5px;}
	
	.popup-menu .name:hover {background-color:rgba(256, 256, 256, 0.8);}
	.popup-menu .color:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	/*pm height 40px*/
	.popup-menu .friend {
		position:absolute;
		display:none;
		
		width:100%;
		height:40px;
		
		transition-duration:0.25s;
	}
	.popup-menu .friend:nth-of-type(1) {border-radius:5px 5px 0px 0px;}
	
	.popup-menu .friend .friend-id {
		position:absolute;
		display:none;
		
		width:100%;
		height:100%;
		
		transition-duration:0.25s;
	}
	.popup-menu .friend .friend-id .id {
		position:absolute;
		opacity:0;
		
		width:100%;
		height:1em;
		
		top:calc(50% - 0.5em);
		
		text-align:center;
		
		transition-duration:0.25s;
	}
	.popup-menu .friend .remove,
	.popup-menu .friend .give {
		position:absolute;
		display:none;
		
		width:50%;
		height:100%;
		
		transition-duration:0.25s;
	}
	.popup-menu .friend .remove {left:0px;}
	.popup-menu .friend .give {left:50%;}
	
	.popup-menu .friend .friend-id:hover,
	.popup-menu .friend .remove:hover,
	.popup-menu .friend .give:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	.popup-menu .add {
		position:absolute;
		display:none;
		
		width:100%;
		height:40px;
		
		top:calc(100% - 40px);
		
		border-radius:0px 0px 5px 5px;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .add:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	/*pm height 40px*/
	.popup-menu .undo {
		position:absolute;
		display:none;
		
		width:100%;
		height:50%;
		
		top:0%;
		
		border-radius:5px 5px 0px 0px;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .undo:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	.popup-menu .ignore {
		position:absolute;
		display:none;
		
		width:100%;
		height:50%;
		
		top:50%;
		
		border-radius:0px 0px 5px 5px;
		
		transition-duration:0.25s;
	}
	
	.popup-menu .ignore:hover {background-color:rgba(256, 256, 256, 0.8);}
	
	.popup-menu img {
		--length:25px;
		
		position:absolute;
		
		width:var(--length);
		height:var(--length);
		
		top:calc(50% - var(--length) / 2);
		left:calc(50% - var(--length) / 2);
	}
		
	/* input창 변화 시작 */
	* {
	  box-sizing: border-box;
	}
	.inp {
	  position: relative;
	  margin: auto;
	  width: 100%;
	  max-width: 280px;
	}
	.inp .label { /* 커서없을때 아이디 */
	  position: absolute;
	  top: 16px;
	  left: 0;
	  font-size: 16px;
	  color: #9098a9;
	  font-weight: 500;
	  transform-origin: 0 0;
	  transition: all 0.2s ease;
	}
	.inp .border { /* focus 밑줄 */
	  position: absolute;
	  bottom: 0;
	  left: 0;
	  height: 2px;
	  width: 100%;
	  background: #0077FF;
	  transform: scaleX(0);
	  transform-origin: 0 0;
	  transition: all 0.15s ease;
	}
	
	.inp input {   /* 커서 */
	  -webkit-appearance: none;
	  width: 100%;
	  border: 0;
	  font-family: inherit;
	  padding: 12px 0;
	  height: 48px;
	  font-size: 16px;
	  font-weight: 500;
	  border-bottom: 2px solid #c8ccd4;
	  background: none;
	  border-radius: 0;
	  color: #223254;
	  transition: all 0.15s ease;
	}
	
	
	.inp input:hover {
	  background: rgba(#223254,0.03);
	}
	.inp input:not(:placeholder-shown) + span { /* 커서없을때 아이디 */
	  color: #5a667f;
	  transform: translateY(-26px) scale(0.75);
	}
	.inp input:focus {
	  background: none;
	  outline: none;
	}
	.inp input:focus + span {  /* focus 아이디 */
	  color: #0077FF;
	  transform: translateY(-26px) scale(0.75);
	}
	.inp input:focus + span + .border {
	  transform: scaleX(1);
	}
	/* input창 변화 끝 */

	/* 계정 정보 수정 */
	.demo {
	  	position: absolute;
	  	top: 2%;
	  	left: 93%;
	  	width: 5rem;
	  	height: 5rem;
	  	overflow: hidden;
		transition-duration:1s;
		z-index:2;
	}
	.login {
	 	position: relative;
	 	height: 100%;
	 	background: linear-gradient(to bottom, rgba(152, 152, 155, 0.18) 0%, rgba(0, 0, 0, 0.4) 100%);
	}
	#icon{
		display: block;
	}
	.myUser{
		opacity: 0;
		transition-duration:1s;
		magin: 0;
		padding: 0;
		border: 0;
		outline: 0;
		width: 40rem;
	  	height: 5.5rem;
		background: transparent;
		border-bottom: 1px solid black; 
		text-align:left;
		padding: 0 0 0 3rem;
		z-index:10;
	}
	
	#deleteuser{
		position : absolute;
		left : 5rem;
		top : 23.5rem;
		border :none;
		background-color : transparent;
		opacity: 0;
		transition-duration:1s;
		display: block;
		z-index:11;
	}
	#logout{
		position : absolute;
		left : 31rem;
		top : 23.5rem;
		border :none;
		background-color : transparent;
		opacity: 0;
		transition-duration:1s;
		display: block;
		z-index:11;
	}
	.myUser span{
		position : absolute;
		left: 14rem;
	}
	/* 계정 정보 수정 */

	/* 계정수정 공통 */
	.inp{
		positions : absolute;
		left : 5rem;
		top : 5rem;
		opacity: 0;
	}
	#back{
		position : absolute;
		left : 5rem;
		top : 23.5rem;
		border :none;
		background-color : transparent;
		opacity: 0;
		transition-duration:1s;
		display: none;
	}
	#next{
		position : absolute;
		left : 31rem;
		top : 23.5rem;
		border :none;
		opacity: 0;
		background-color : transparent;
		transition-duration:1s;
		display: none;
	}
	#confirming{
		position : absolute;
		left : 31rem;
		top : 23.5rem;
		border :none;
		opacity: 0;
		background-color : transparent;
		transition-duration:1s;
		display: none;
	}
	
	/* 이름변경 */
	#nameColor{
		position : absolute;
		left : 5rem;
		top : 10rem;
		transition-duration:1s;
		display: none;
	}
	#nameError{
		opacity: 0;
		position : absolute;
		left : 5rem;
		top : 16rem;
		display: none;
	}

	/* 비밀번호변경 */
	#pwColor{
	position : absolute;
		left : 5rem;
		top : 5rem;
		transition-duration:1s;
		display: none;
	}
	#pwError{
		opacity: 0;
		position : absolute;
		left : 5rem;
		top : 10rem;
		transition-duration:1s;
		display: none;
	}
	#pwCheck{
		position : absolute;
		left : 5rem;
		top : 13rem;
		transition-duration:1s;
		display: none;
	}
	#pwckError{
		position : absolute;
		left : 5rem;
		top : 18rem;
		transition-duration:1s;
		opacity: 0;
		display: none;
	}
	
	/* 이메일 변경 */
	#emailColor{
		position : absolute;
		left : 5rem;
		top : 10rem;
		transition-duration:1s;
		display: none;
	}
	#emailError{
		opacity: 0;
		position : absolute;
		left : 5rem;
		top : 16rem;
		display: none;
	}
	
	
	/* 계정 삭제*/
	#delMsg1{
	position : absolute;
		left : 5rem;
		top : 7rem;
		transition-duration:1s;
		display: none;
	}
	#delMsg2{
	position : absolute;
		left : 5rem;
		top : 11rem;
		transition-duration:1s;
		display: none;
	}
	#delMsg3{
	position : absolute;
		left : 5rem;
		top : 17rem;
		transition-duration:1s;
		display: none;
	}
	.tomain {
		z-index:1;
		position:fixed;
		left:0%;
		top:0%;
		width:100%;
		height:100%;
		cursor:pointer;
		display: none;
	}
	
	
</style>
</head>
<body>
	<% User corUser = (User)session.getAttribute("corUser"); %>
	
	<!-- 사용자정보 관리 목록 -->
	<div class="tomain"></div>
	<div class="demo">
		<div class="login">
			<!-- icon -->
			<img width="50" height="50" src="/note/img/friend.png" id="icon">
			
			<!-- 계정 정보 --> 
			<button class="myUser">아이디<span>${corUser.userId}</span></button>
			<button class="myUser" id="nameUser">이름<span>${corUser.userName}</span></button>
			<button class="myUser" id="pwUser">비밀번호<span>변경하려면 클릭</span></button>
			<button class="myUser" id="emailUser">이메일<span>${corUser.userEmail}</span></button>
			
			<button id="deleteuser"><img src="img/deleteuser.png" style="width: 30px;"></button>
			<button id="logout"><img src="/note/img/logout.png" style="width: 26px;"></button>
		
			<!-- 이름 변경 -->
			<label for="inp" class="inp" id="nameColor"><input type="text" name="userName" placeholder="&nbsp;" autocomplete="off"><span class="label">이름</span><span class="border"></></label>
			<p id="nameError"></p>
			
			<button type="button" id="back"><img src="img/back.png"></button>
			<button type="button" id="next"><img src="img/next.png" style="width: 30px;"></button>
		
			<!-- 비밀번호 변경 -->
			<label for="inp" class="inp" id="pwColor"><input type="password" name="userPw" placeholder="&nbsp;" autocomplete="off"><span class="label">비밀번호</span><span class="border"></span></label>
			<p id="pwError"></p>
			<label for="inp" class="inp" id="pwCheck"><input type="password" name="checkPw" placeholder="&nbsp;" autocomplete="off"><span class="label">비밀번호확인</span><span class="border"></span></label>
			<p id="pwckError"></p>

			<!--  이메일 변경 -->
			<label for="inp" class="inp" id="emailColor"><input type="text" name="userEmail" placeholder="&nbsp;" autocomplete="off"><span class="label">이메일</span><span class="border"></span></label>
			<p id="emailError"></p>
		
			<!--  계정 삭제 -->
			<p id="delMsg1">note를 사용하는 계정을 삭제하려고 합니다</p>
			<p id="delMsg2">계정이 가진 정보와 데이터는 삭제됩니다</p>		
			<label id="delMsg3"><input type="checkbox" required />예. note의 계정과 데이터를 삭제하고자 합니다.</label>
			<button type="button" id="confirming"><img src="img/circle.png"></button>
		</div>
	</div> 
	
	<!-- 노트 -->
	<br>
	<br>
	<br>
	<br>

	<form id="showNote" method="post" action="/note/note" target="noteFrame">
		<input type="hidden" name="noteId" value="">
		<input type="hidden" name="noteIdx" value="">
		<input type="hidden" name="noteName" value="">
		<input type="hidden" name="noteColor" value="">
		<input type="submit">
	</form>
	
	<form id="refresh" method="post" action="/note/main">
		<input type="submit">
	</form>
	
	<iframe name="noteFrame" allowtransparency="true" frameborder="0" width="30px" height="300px"></iframe>

	<div class="popup-menu">
		<div class="edit"><img src="/note/img/edit.png"></div>
			<div class="name"><img src="/note/img/rename.png"></div>
				<div class="name-in"><input type="text" placeholder="new name"></div>
			<div class="color"><img src="/note/img/color.png"></div>
				<div class="colors">
					<div class="a"></div>
					<div class="b"></div>
					<div class="c"></div>
					<div class="d"></div>
					<div class="e"></div>
					<div class="f"></div>
					<div class="color-in"><input type="text" placeholder="rgba(r, g, b, a)"></div>
				</div>
				
		<div class="share"><img src="/note/img/friend.png"></div>
			<!-- <div class="friend">
				<div class="friend-id"><span class="id"></span></div>
				<div class="remove"><img src="/note/img/delete.png"></div>
				<div class="give"><img src="/note/img/give.png"></div>
			</div> -->
			
			<div class="add"><img src="/note/img/add.png"></div>
				<div class="friend-in"><input type="text" placeholder="friend's ID"></div>
			
		<div class="delete"><img src="/note/img/delete.png"></div>
			<div class="undo"><img src="/note/img/undo.png"></div>
			<div class="ignore"><img src="/note/img/ignore.png"></div>
	</div>

	<div class="shelf">	
		<div class="scene" 
			style="	--note-color:transparent; 
						--note-line-color:transparent; 
						--note-page-color:transparent;
						cursor:pointer;">
			<div class="shadow"></div>
			
			<div class="note mock show-front">
				<div class="side front mock">
					<div class="name"></div>
					<div class="line mock"></div>
				</div>
				
				<div class="side back mock">
					<div class="line-up mock"></div>
					<div class="line-down mock"></div>
				</div>
				
				<div class="side right">
					<div class="cover mock"></div>
					<div class="page mock"></div>
					<div class="cover mock"></div>
				</div>
				
				<div class="side left mock"></div>
				
				<div class="side up">
					<div class="cover-side mock"></div>
					<div class="cover mock"></div>
					<div class="page mock"></div>
					<div class="cover mock"></div>
					<div class="line mock"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side mock"></div>
					<div class="cover mock"></div>
					<div class="page mock"></div>
					<div class="cover mock"></div>
					<div class="line mock"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover mock"></div>
					<div class="page mock"></div>
					<div class="cover mock"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover mock"></div>
					<div class="page mock"></div>
					<div class="cover mock"></div>
				</div>
			</div>
		</div>
<%
	List<Note> notes = (List<Note>)request.getAttribute("notes");
	List<UserNote> userNotes = (List<UserNote>)request.getAttribute("userNotes");
	
	for(UserNote userNote : userNotes) {
		for(Note note : notes) {
			if(userNote.getNoteId() == note.getId()) {
%>
		<div class="scene" style="--note-color:<%= note.getColor() %>;">
			<div class="shadow"></div>
			
			<div class="note show-front">
				<div class="side front">
					<div class="name"><%= note.getName() %></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
			
			<div class="meta">
				<div class="id">
					<%= note.getId() %>
				</div>
				<div class="name">
					<%= note.getName() %>
				</div>
				<div class="idx">
					<%= userNote.getNoteIdx() %>
				</div>
				<div class="color">
					<%= note.getColor() %>
				</div>
				<div class="sharedCnt">
					<%= note.getShareCnt() %>
				</div>
			</div>
		</div>
<%
			}
		}
	}
%>
		
		<div id="pusher" class="scene">
			<div class="shadow"></div>
			
			<div class="note">
				<div class="side front">
					<div class="name"></div>
					<div class="line"></div>
				</div>
				
				<div class="side back">
					<div class="line-up"></div>
					<div class="line-down"></div>
				</div>
				
				<div class="side right">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side left"></div>
				
				<div class="side up">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side down">
					<div class="cover-side"></div>
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
					<div class="line"></div>
				</div>
				
				<div class="side edge-down">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
				
				<div class="side edge-up">
					<div class="cover"></div>
					<div class="page"></div>
					<div class="cover"></div>
				</div>
			</div>
		</div>
		
		<div class="support"></div>
	</div>
</body>
</html>
