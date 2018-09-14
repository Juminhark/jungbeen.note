function triggerEvent(el, type, ev){
	   if ('createEvent' in document) {
        // modern browsers, IE9+
        var e = document.createEvent('HTMLEvents');
        e.initEvent(type, false, true);
        el.dispatchEvent(e);
    } else {
        // IE 8
        var e = document.createEventObject();
        e.eventType = type;
        el.fireEvent('on'+e.eventType, e);
    }
}

function getCssVar(variable) {
	return document.querySelector(":root").style.getPropertyValue("--" + variable);
}

function setCssVar(name, value) {
	document.querySelector(":root").style.setProperty("--" + name, value);
}

function removeClass(name) {
	do {
		var node = document.getElementsByClassName(name)[0];
		node.classList.remove(name);
		node = document.getElementsByClassName(name)[0];
	} while(node != undefined);
}

function ajax(option) {
	var url = option.url;
	var method = option.method;
	
	var success = option.success;
	var failed = option.failed;
	var progress = option.progress;
	var loadstart = option.loadstart;
	var loadend = option.loadend;
	
	var param = option.param;
	var params = "";
	
	var data = option.data;
	
	var serialize = option.serialize;
	if(serialize == undefined)
		serialize = false;
	
	var contentType = option.contentType;
	
	var xhr = new XMLHttpRequest();
	xhr.open(method, url, true);
	
	xhr.onreadystatechange = function(e) {					
		if(xhr.readyState == 4) {
			if(xhr.status == 200) {
				// 200 정상 응답
				var response;
				
				try {
					response = JSON.parse(this.responseText);
				} catch(err) {
					response = this.responseText;
				}
				
				if(success != undefined)
					success(response);
			} else if(xhr.status == 500) {
				//500 서버 에러
				var response;
				
				try {
					response = JSON.parse(this.responseText);
				} catch(err) {
					response = this.responseText;
				}
				
				if(failed != undefined)
					failed(response);
			}
		}
	}
	
	if(progress != undefined)
		xhr.upload.onprogress = function(e) {
			progress(e);
		}
	
	if(loadstart != undefined)
		xhr.upload.onloadstart = function(e) {
			loadstart(e);
		}
	
	if(loadend != undefined)
		xhr.upload.onloadend = function(e) {
			loadend(e);
		}
	
	if(!serialize)
		//xhr.setRequestHeader("Content-type", "multipart/formed-data");
		//xhr.setRequestHeader("Content-type", contentType);
		xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded;  charset=utf-8");
	
	if(param != undefined) {
		for(var i = 0; i < param.length; i++)
			if(i != param.length - 1)
				params += param[i].name + "=" + param[i].value + "&";
			else
				params += param[i].name + "=" + param[i].value;

		xhr.send(params);
	} else if (data != undefined) {
		xhr.send(data);
	}
}

function getStyle(el, css) {
	return window.getComputedStyle(el , null).getPropertyValue(css);
}

function findAncestor(el, anc) {
	var anc = typeof anc === "string" ? document.querySelector(anc) : anc;
	if(el != anc)
		while((el = el.parentElement) && el != anc);
	return el;
}