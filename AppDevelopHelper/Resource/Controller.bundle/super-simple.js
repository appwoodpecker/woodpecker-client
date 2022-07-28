                                
//request controller hierarchy from App

function loadControllerHierarchy(callback) {
	adhCallClientApi('adh.controller-hierarchy','hierarchy',{},'',function (data,payload) {
		var content = data["content"];
		var chart = renderChart(content);
		if(callback != null && typeof callback == "function") {
			callback(chart);
		}
	});
}

function renderChart(content) {
    var dark = isDark();
	var hierarchyData = JSON.parse(content);
	var nodeData = traverseRenderNodeWithData(hierarchyData);
	var chart = {
		"chart" : {
			container: "#chart",
			rootOrientation: "NORTH",
			levelSeparation: 50,	 	
			siblingSeparation: 50,   	
			subTeeSeparation: 50,		
			hideRootNode: false,		
			animateOnInit: false,
			//connector style
			connectors: {
				type: "curve",
			},
			//node style
			node: {
				
			},
			callback: {
				onCreateNode: function(tree,node){
					 var tags = node.getElementsByTagName('p');
					 for (var i = 0; i < tags.length; i++) {
					 	var tag = tags[i];
					 	var text = tag.innerHTML;
					 	if(text != null && text.length > 0) {
					 		tag.setAttribute('title',text);
					 	}
                         if(dark) {
                             if(tag.className == 'node-name') {
                                tag.style.color = '#EEE';
                             }else if(tag.className == 'node-title') {
                                tag.style.color = '#FFF';
                             }else if(tag.className == 'node-desc') {
                                tag.style.color = '#999';
                             }
                         }
  					 }
				},
				onTreeLoaded: function(tree) {
					
				}
			}
		},
		"nodeStructure" : nodeData,
	};
	return chart;
}

var themeConfig = {
	"node": "#25A261",
  	"navnode" : "#868FC7",
  	"tabnode" : "#8C7171",
  	"pagenode" : "#646499",
  	"containernode" : "#2BA1D4",
  	"presentnode" : "#D2C355",
};

function traverseRenderNodeWithData(data) {
    var node = {};
	var text = {};
	var typeText = '';
	
	var childrenNodes = new Array();
	var children = data['children'];
	var isContainer = (children != null && children.length > 0);
	if(isContainer) {
		for (var i = 0; i < children.length; i++) {
			 var childData = children[i];
			 var childNode = traverseRenderNodeWithData(childData);
			 childrenNodes.push(childNode);
		 }
	}
	var isPresenting = (data['presentedChild'] != null);
	if(isPresenting) {
		var presentedChild = data['presentedChild'];
		var presentedNode = traverseRenderNodeWithData(presentedChild);
		var nodeClass = presentedNode['HTMLclass'];
		if(nodeClass == null) {
			nodeClass = 'presentednode';
		}else {
			nodeClass += ' presentednode';
		}
		presentedNode['HTMLclass'] = nodeClass;
		childrenNodes.push(presentedNode);
	}
	
	node['children'] = childrenNodes;
	var type = data['type'];
	var nodeClass = '';
	if(isContainer) {
		if(type == 1) {
			nodeClass = 'navnode';
			typeText = 'Navigation';
		}else if(type == 2) {
			nodeClass = 'tabnode';
			typeText = 'TabBar';
		}else if(type == 3) {
			nodeClass = 'pagenode';
			typeText = 'PageView';
		}else {
			nodeClass = 'containernode';
			typeText = 'Container';
		}
	}else {
		if(isPresenting) {
			nodeClass = 'presentnode';
		}
	}
	if(data['visible'] == '1') {
		if(nodeClass.length > 0) {
			nodeClass += ' visiblenode';
		}else {
			nodeClass = 'visiblenode';
		}	
	}
	if(nodeClass.length > 0) {
		node['HTMLclass'] = nodeClass;
	}
	var themeColorKey = nodeClass;
	if(themeColorKey.length == 0) {
		themeColorKey = 'node';
	}
	var themeColor = themeConfig[themeColorKey];
	node['connectors'] = {
		style: {
			stroke : themeColor,
		}
	};

	var title = data['title'];
	if(title == null || title.length==0) {
		if(typeText.length > 0) {
			title = typeText; 
		}else {
			title = '-';
		}
	}
	var className = data['className'];
	if(className == null || className.length == 0) {
		className = '-';
	}
	var address = data['address'];
	if(address == null || address.length == 0) {
		address = '';
	}

	text['name'] = title;
	text['title'] = className;
	text['desc'] = address;
	node['text'] = text;
    
	return node;
} 
