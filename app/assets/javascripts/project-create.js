function loadProject() {

	bindInputs('#proj-title-input', '#createProjectBoxWrap .proj-area-title', 'Project Title');
	bindInputs('.locationField', '#createProjectBoxWrap .projLoc', 'Project Location');
	bindInputs('.briefTextArea', '#createProjectBoxWrap .proj-area-paragraph', 'Brieft Project Description');
	bindInputs('.daysLeftInput', '#createProjectBoxWrap .daysLeft', '0');
	bindInputs('.textamount ', '#createProjectBoxWrap .target', '0');

	$('.project-signup-url').live({
		
		focusin : function() {
			if (this.value == 'Enter your video URL here')
				$(this).val('');
		},
		
		focusout : function() {
			
			if (this.value == '')
				$(this).val("Enter your video URL here");
			else {
				var url = grabYoutubeLink($(this).val());
				$('#videoPreview').html("<iframe width='220' height='125' src='http://www.youtube.com/embed/"+url+"' frameborder='0' allowfullscreen></iframe>");
			}
		}
	});
	
	$('#imgButton').live('click', function() {
		$('#videoButton').show();
		reset('url-input-parent');
		$(this).hide();
		$('#videoPreview').hide()
	});
	
	$('#videoButton').live('click', function() {
		$('#videoPreview').show();
		
		$('#imgButton').show();
		reset('file-input-parent');
		$(this).hide();
	});
	
	function reset(id) {
		$('#'+id).html($('#'+id).html());
	}
	
	function bindInputs(input, dest, defaultValue) {
		$(input).bind({
	        onchange: function () {
                if (this.value == '')
					$(dest).html(defaultValue);
				else
					$(dest).html(this.value);
            },
			keyup : function() {
				if (this.value == '')
					$(dest).html(defaultValue);
				else
					$(dest).html(this.value);
			}
		});
	}
	
	function grabYoutubeLink(url) {
		
		var str = '';
		
		if ( url.indexOf('youtu.be') != -1 ) {
			str = url.substring(url.indexOf('.be')+4);
		}
		else {
			str = url.substring(url.indexOf('=')+1);
			if ( str.indexOf('&') != -1 ) {
				str = str.substring(0, str.indexOf('&'));
			}
		}
		
		return str;
	}
	
	$(window).scroll( function() {
		var box = $('#createProjectBoxWrap');
		var pos = box.position();
		var body = $('body');
		var scrollTop = body.scrollTop();
		
//		if ( scrollTop > 260 && scrollTop < 580 ) {
//			box.css('top', 160+scrollTop-260);
//		}
//
//		else if ( body.scrollTop() < 260 ) {
//			box.css('top', 160);
//		}
//
//		else if ( scrollTop > 590 ) {
//			box.css('top', 480);
//		}
			
	});
}

