/*
 * extanted range's method.
 * 
 * surroundContents.
 * 		: wrap every text node between startNode, endNode.
 * 		param:{
 * 			[opt]range:Range, 
 * 			tagName:String, 
 * 			[opt]attribute:[{name:String, value:String}, ...]
 *		}
 * 
 * releaseContents.
 * 		: unwrap every connected text node at selection.
 * 		param:{
 * 			[opt]range:Range,
 * 			[opt]root:DOMCollection or Selector,
 * 			[chk]tagName:String,
 * 			[chk]attribute:[{[chk]name:String, [chk]value:Stirng}, ...]
 * 		}
 * 
 * setRange.
 * 		: set the range
 * 		param:{
 * 			startNode:Node, 
 * 			endNode:Node, 
 * 			[opt]startOffset:Number,
 * 			[opt]endOffset:Number
 * 		}
 * 		return:selecton
 * 
 * insertNode.
 * 		: insert node
 * 		param:{
 * 			[opt]range:Range
 * 			[radio]text:String, 
 * 			[radio]tagName:String,
 * 			[opt]atrribute:[{name:String, value:String}, ...],
 * 		}
 *   
 */
var RangeEx = {
	surroundContents:
		function(setting) {
		    var sel = window.getSelection();
		
		    if(!sel.isCollapsed) {
		    
			    var range = sel.getRangeAt(0);
			    if (setting.range != undefined)
			        range = setting.range;
			
			    var tag = document.createElement(setting.tagName);
			    tag.setAttribute("data-state", "just_inserted");
			    if(setting.attribute != undefined)
			        for (var i = 0; i < setting.attribute.length; i++)
			            tag.setAttribute(setting.attribute[i].name, setting.attribute[i].value);
			
			    var startNode = range.startContainer; var startOffset = range.startOffset;
			    var endNode = range.endContainer; var endOffset = range.endOffset;
			    var ancestorNode = range.commonAncestorContainer;
		
			    var log = [];
			    
			    var cursorNode = startNode;
			    do {    	
			    	/*
			    	 * cursorNode를 가장 하위 노드로 끌어 내린다.
			    	 */
			    	while(cursorNode.nodeName != "#text")
			    		if(cursorNode.childNodes[0] != undefined)
			    			cursorNode = cursorNode.childNodes[0];
			    		else
			    			break;
			    	
			    	/*
			    	 * cursorNode가 endNode가 아니면,
			    	 */
			        if (cursorNode != endNode) {
			            log.push(cursorNode);
			            
			            /*
			             * cursorNode 다음에 노드가 존재하고,
			             * cursorNode의 부모 노드가 ancestorNode가 아닐 때까지,
			             * 상위 노드로 끌어 올린다.  
			             */
		            	while(cursorNode.nextSibling == null &&
		            			cursorNode.parentElement != ancestorNode)
		            		cursorNode = cursorNode.parentElement;
		
			            cursorNode = cursorNode.nextSibling;
			        }
			        
			        if (cursorNode == endNode)
			            log.push(cursorNode);
			        
			    } while (cursorNode != endNode);
			    
			    for (var i = 0; i < log.length; i++) {
			        if (log[i].nodeName == "#text") {
			        	if(log.length == 1) {
			        		this.setRange({startNode:log[i], endNode:log[i], startOffset:startOffset, endOffset:endOffset})
			        			.getRangeAt(0).surroundContents(tag.cloneNode());
			        		break;
			        	}
			        	
			            if (i == 0) {
			                this.setRange({ startNode: log[i], endNode: log[i], startOffset: startOffset })
			                    .getRangeAt(0).surroundContents(tag.cloneNode());
			            } else if (i == log.length - 1) {
			                this.setRange({ startNode: log[i], endNode: log[i], endOffset: endOffset })
			                    .getRangeAt(0).surroundContents(tag.cloneNode());
			            } else {
			                this.setRange({ startNode: log[i], endNode: log[i] })
			                    .getRangeAt(0).surroundContents(tag.cloneNode());
			            }
			        }
			    }
			    
			    var target = document.querySelectorAll("[data-state='just_inserted']");
			    
			    this.setRange({startNode:target[0], endNode:target[target.length-1]});
			    
			    for(var i = 0; i < target.length; i++)
			    	target[i].removeAttribute("data-state");
		    }
		},
		
	releaseContents:
		function(setting) {
			var sel = window.getSelection();
			
		    if(!sel.isCollapsed) {
		    
			    var range = sel.getRangeAt(0);
			    if (setting.range != undefined)
			        range = setting.range;
			    
			    var tagName = setting.tagName;
			    var attribute = setting.attribute;
			    
			    var root = setting.root;
			    
			    var startNode = range.startContainer; var startOffset = range.startOffset;
			    var endNode = range.endContainer; var endOffset = range.endOffset;
			    var ancestorNode = setting.root;
			    
			    if(ancestorNode == undefined)
			    	if(findAncestor(startNode, ancestorNode) &&
			    			findAncestor(endNode, ancestorNode))
			    		ancestorNode = range.commonAncestorContainer;
			    	else
			    		ancestorNode = range.commonAncestorContainer.parentNode;
			    
			    var log = [];
			    var isCorrect = [false, false];
			    var dropIt = true;
			    
			    var cursorNode = startNode;
			    do {
			    	/*
			    	 * cursorNode를 가장 하위 노드로 끌어 내린다.
			    	 */
			    	if(dropIt) {
			    		while(cursorNode.nodeName != "#text")
				    		if(cursorNode.childNodes[0] != undefined)
				    			cursorNode = cursorNode.childNodes[0];
				    		else
				    			break;
			    		
			    		/*
			    		 * 텍스트 노드를 한칸 상위로 끌어올린다.
			    		 */
			    		if(cursorNode.parentNode != ancestorNode)
			    			cursorNode = cursorNode.parentNode;

			    		dropIt = false;
			    	}
			    	
			    	/*
			    	 * cursorNode가 조건에 부합되는지 검사하고
			    	 * 부합된다면 log에 담는다.
			    	 */
			    	if(cursorNode.nodeName != "#text")
				    	if(tagName != undefined && 
	    						cursorNode.nodeName == tagName.toUpperCase())
	    					isCorrect[0] = true;
				    	else
				    		isCorrect[0] = true;
	    				
			    	if(cursorNode.nodeName != "#text")
	    				if(attribute != undefined) {
	    					for(var i = 0; i < attribute.length; i++)
	    						if(attribute[i].value != undefined &&
	    								cursorNode.getAttribute(attribute[i].name) == attribute[i].value) {
	    							isCorrect[1] = true;
	    						} else if(attribute[i].value == undefined &&
	    								cursorNode.getAttribute(attribute[i].name)) {
	    							isCorrect[1] = true;
	    						}
	    				} else
	    					isCorrect[1] = true;
			    	
    				if(isCorrect[0] && isCorrect[1])
    					log.push(cursorNode);
			    	
			    	/*
			    	 * cursorNode가 endNode나 ancestorNode가 아니고
			    	 */
			    	if(cursorNode != endNode &&
			    			cursorNode.parentNode != ancestorNode) {
			    		/*
			    		 * 다음 노드가 있으면 cursorNode를 한칸 다음으로 옮긴다.
			    		 * 다음 노드가 없고 상위 노드가 있다면 cursorNode를 한칸 상위로 끌어 올린다.
			    		 */
			    		if(cursorNode.nextSibling != null) {
			    			cursorNode = cursorNode.nextSibling;
			    			
			    			/*
			    			 * 가장 하위 노드로 끌어내린다. [지시]
			    			 */
			    			dropIt = true;
			    		} else if(cursorNode.parentNode != null)
			    			cursorNode = cursorNode.parentNode;
			    	} else
			    		break;
			    } while (cursorNode != endNode);
			    
			    /*
			     * log에 담겨온 조건에 부합하는 노드들에 대해서
			     * 텍스트를 모두 꺼낸다.
			     */
			    for (var i = 0; i < log.length; i++) {
			    	var parentNode = log[i].parentNode;
			    	
		        	while(log[i].firstChild)
		        		parentNode.insertBefore(log[i].firstChild, log[i]);
		        	
		        	parentNode.removeChild(log[i]);
			    }
		    }
		},
	
	setRange:
		function(setting) {
		    var startNode = setting.startNode;
		    var endNode = setting.endNode;
		
		    var startOffset = setting.startOffset;
		    if (startOffset == undefined)
		        startOffset = 0;
		
		    var endOffset = setting.endOffset;
		    if (endOffset == undefined)
		        if (endNode.nodeName == "#text")
		            endOffset = endNode.length;
		        else
		            endOffset = endNode.childNodes.length;
		    
		    var range = document.createRange();
		    range.setStart(startNode, startOffset);
		    range.setEnd(endNode, endOffset);
		
		    var sel = window.getSelection();
		    sel.removeAllRanges();
		    sel.addRange(range);
		
		    return sel;
		},
		
	insertNode:
		function(setting) {
			var sel = window.getSelection();
			
			var range = sel.getRangeAt(0);
			if(setting.range != undefined)
				range = setting.range;
			
			var attribute = "";
			if(setting.attribute != undefined)
				for(var i = 0; i < setting.attribute.length; i++)
					setting.attribute[i].name
			
			var node;
			if(setting.tagName != undefined) {
				node = document.createElement(setting.tagName);
				
				if(setting.text != undefined)
					node.innerText = setting.text;
				
				if(setting.attribute != undefined)
					for(var i = 0; i < setting.attribute.length; i++)
						node.setAttribute(setting.attribute[i].name, setting.attribute[i].value);
			}
			else
				node = document.createTextNode(setting.text);
			
			range.insertNode(node);
			
			range.setStartAfter(node);
			range.setEndAfter(node); 
			
			sel.removeAllRanges();
			sel.addRange(range);
		}
}

function findAncestor(el, anc) {
	var anc = typeof anc === "string" ? document.querySelector(anc) : anc;
	if(el != anc)
		while((el = el.parentElement) && el != anc);
	return el;
}