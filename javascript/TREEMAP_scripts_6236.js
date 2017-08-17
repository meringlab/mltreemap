function NEWSTRING_toggleAbstractState (abstract_id, event) {

    // if this routine has been triggered from an image, bail out. All images are within <a> tags and cause their own actions.

    if (event) { 
	if (event.target) { if (event.target == '[object HTMLImageElement]') { return; } }
	if (event.srcElement) { if (event.srcElement.tagName == 'IMG') { return; } }
    }

    toggle_visualizer_element_id = "TV_" + abstract_id;
    toggle_visualizer_element = document.getElementById (toggle_visualizer_element_id) || toggle_visualizer_element_id;
    abstract_body_element_id = "AB_" + abstract_id;	
    abstract_body_element = document.getElementById (abstract_body_element_id) || abstract_body_element_id;
    match_summary_element_id = "MS_" + abstract_id;
    match_summary_element = document.getElementById (match_summary_element_id) || match_summary_element_id;
  
    if (abstract_body_element.style.display=='none') {
        abstract_body_element.style.display='block';
	match_summary_element.style.display='none';
	toggle_visualizer_element.className = 'TV_expanded';
    } else {
        abstract_body_element.style.display='none';
        match_summary_element.style.display='block';
	toggle_visualizer_element.className = 'TV_collapsed';
    }
}
