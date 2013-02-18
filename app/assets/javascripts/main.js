$(window).load( function() {
	
	loadFeedbackForm();
	
	var body = $('body');

	$(".closeConfirm").live("click", function() {
			$(".confirmBox").remove();
	});

	function confirmMessage(message) {
		var body = $("body");

		var confirmBox = $("<div class='confirmBox success'>" +
								"<div class='closeConfirm'></div>" +
								message +
							"</div>");


		var header = $(".topHeader");

		header.after(confirmBox);
	}

	function errorMessage(message) {
		var body = $("body");

		var confirmBox = $("<div class='confirmBox error'>" +
								"<div class='closeConfirm'></div>" +
								message +
							"</div>");


		var header = $(".topHeader");

		header.after(confirmBox);
	}

	function popup() {

		var body = $("body");
		body.append("<div class='backdrop'></div>");

		var backdrop = $(".backdrop");

		var popupwrap = $("<div class='popupwrap'></div>");
		body.prepend(popupwrap);

		var popup = $("<div class='popup'></div>");

		$(window).resize(function() {

			var windowheight = $(window).height();
			var popupheight = popup.outerHeight();

			popup.css("margin-top", (windowheight - popupheight)/2);
		});

		popupwrap.append(popup);

		popupwrap.click( function() {

			$(this).remove();
			backdrop.remove();
			$('body').css('overflow', 'scroll');
		});

		popup.click( function() {
			return false;
		});

		var leftwrap = "<div class='popupleft'>" +
							"<div class='popuptitle'>Make your donation</div>" +
							"<div class='popupcontent'>Thanks for your interest in the <a class='weeve-link'>New Shelter for Women and Children</a> project!  Make sure you review the 'Things to know' to the right before you make your donation!</div>" +
							"<div class='popupcontent'>How much would you like to donate?</div>" +
							"<input type='text' class='popupinput'></input><div class='popupinputhint'>Any amount you want!<br/>$1 minimum please</div>" +
							"<button class='popupsubmit weeve-medium-button'>Continue to PayPal</button>" +
					   "</div>";
		var rightwrap = "<div class='popupright'>" +
							"<div class='fintprinttitle'>Things to know</div>" +
							"<div class='fintprint'>Once your enter your donation amount, you will be taken to PayPal to complete the donation process.  PayPal is secure and a trusted source for online transactions.</div>" +
							"<div class='fintprint'>If the project is successful, your credit card will be charged on Friday, Jan 20, 11:59pm EST.</div>" +
							"<div class='fintprint'>You can change or cancel your donation anytime before Friday, Jan 20, 11:59pm EST.</div>" +
						"</div>";
		var title = "<div class='popuptitle'>Make your donation</div>";
		var projectname = "<div class='project'>New Shelter for Women and Chidlren</div>";

		var close = $("<div class='popupclose weeve-link'>close</div>");

		close.click( function() {
			popupwrap.remove();
			backdrop.remove();
			$('body').css('overflow', 'scroll');
		});

		popup.append(leftwrap);
		popup.append(rightwrap);
		popup.append(close);

		$('body').css('overflow', 'hidden');

		$(window).resize();
	}

});

function loadFeedbackForm() {
	var animateTime = 350;
	$('#feedbackButton').data('expanded', false);
	
	$('#feedback-submit').click( function() {
		if ( $('#feedback-subject').val() == '' || $('#feedback-message').val() == '') {
			alert('Subject and Message are both required.');
			return false;
		}
	});
	
	$('#feedbackButton').click( function() {
		if ( $('#feedbackButton').data('expanded') == false ) {
			$('#feedbackWrap').animate({
				right: 0
	        }, animateTime, function() {
				$('#feedbackButton').data('expanded', true);
			});
		}
		else {
			$('#feedbackWrap').animate({
				right: -481
	        }, animateTime, function() {
				$('#feedbackButton').data('expanded', false);
			});
		}
	});
}

function loginSetup() {
	var loginlink = $('.login-link');

	if ( loginlink )  {
		setupLogin();

		loginlink.click( function() {
			
			positionLogin();

			$(".login-box-wrap").css('display', 'block');
			$(".login-field").focus();
			return false;
		});

		$(window).resize( function() {
			positionLogin();
		});
	}
}

function positionLogin() {
	var wrapper = $(".login-box-wrap");
	var loginlink = $('.login-link');
    var container = $('.headercontent');
	linkpos = loginlink.position();
    contpos = container.position();
	wrapper.css("left", linkpos.left);
	wrapper.css("top", linkpos.top + loginlink.outerHeight()*2 + 2);
}

function setupLogin() {

	var body = $('body');
	var loginlink = $('.login-link');

	var wrapper = $(".login-box-wrap");
	linkpos = loginlink.position();

	wrapper.hide();

	loginlink.hover();

	positionLogin();

	body.click( function() {
		
		if ( !$("#login-box").data('popupOpened') ) {
			wrapper.hide();
		}
		$("#login-box").data('popupOpened', false);
	});

	wrapper.click ( function(e) {
		
        if ( e.target.id != 'login-button' && e.target.id != 'forgot-link' && e.target.id != 'facebook-login')
            return false;
	});
}

function counter(target, max, area) {


    $('#'+target).html(max-$('#'+area).val().length);

    $('#'+area).bind({
        keyup : function() {
            $('#'+target).html(max-this.value.length)
        }
    });
}

function linkTextAreas(orig, dest) {

    $('#'+orig).bind({
        keyup : function() {
            alert('ha');
            $('#'+dest).html($(this).val())
        }
    });
}

function autocomplete(id) {
    var geocoder = new google.maps.Geocoder();

	$('#'+id).live('focus', function(){
		$(this).autocomplete({
			source: function(request, response) {
			  geocoder.geocode( {'address': request.term}, function(results, status) {
				$("#map_location").attr("value","");
				response($.map(results, function(item) {

					var city = '';
					var province = '';
					for (var i = 0; i < item.address_components.length; i++ ) {
						if (item.address_components[i].types[0] == 'locality')
							city = item.address_components[i].short_name;
						if (item.address_components[i].types[0] == 'administrative_area_level_1')
							province = item.address_components[i].short_name;
					}

					value = city + ', ' + province;
				  return {
					label: item.formatted_address,
					value: value,
					location: item.geometry.location,
					addr: item.address_components[0]
				  }
				}));
			  })
			},
			minLength: 3,
			select: function(event, ui) {
			   $("#map_location").html("Latitude: " + ui.item.location.lat() + " Longitude: "+ ui.item.location.lng());
			}
	  });
	});
}

function loadPopup() {

    var close = $(".popupclose");

    close.click( function() {
        $('.popupContainer').hide();
        $('body').css('overflow', 'scroll');
    });

    $(".popupLeft form").submit( function() {
        var donation = $("#donationInput").val();
        var pat = /^[0-9]+$/;
        if ( !pat.test(donation) ){
            alert("Only whole dollar amounts are allowed as a donation.");
            return false;
        }
    });
}

function loadPopupLogin() {
	$('#popupLoginLink').click( function() {
		$('body').css('overflow', 'scroll');
		$('#donationNonuserPopup').hide();
		$("#login-box").css('display', 'block');
		$("#usernameField").focus();
		$("#login-box").data('popupOpened', true);
	});
	
	$('#chooseNonuser').click( function() {
		$('#donationChoose').hide();
		$('#guestDonationForm').css('display', 'table');
	});
}

function loadDonateButton() {
    $('.donate-button').click( function() {
        $('body').css('overflow', 'hidden');
        $('#donationPopup').show();
    });
}

function loadNonuserDonateButton() {
    $('.donate-button-nonuser').click( function() {
		$('#donationChoose').css('display', 'table');
		$('#guestDonationForm').hide();
        $('body').css('overflow', 'hidden');
        $('#donationNonuserPopup').show();
    });
}

function loadEmbedPopup() {

    $('.embedButton').click( function() {
        $('body').css('overflow', 'hidden');
        $('#embedPopup').show();
    });
}

function loadEmbedInput() {
    $('#embedInput').click( function() {
        this.select();
    });

    var close = $(".popupclose");

    close.click( function() {
        $('.popupContainer').hide();
        $('body').css('overflow', 'scroll');
    });
}

function loadSubscribers() {

    var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;

    $(".subscribeFormWrap form").submit( function() {
        if ( !emailPattern.test($('#subField').val()) ) {
            alert("Please type in a valid email");
            return false;
        }
    });
}

function loadIndex() {
    var current = $('#usersButton');
    var currentWrap = $('.userWrap');
    var animationTime = 300;

    $("#nposButton").click( function() {
        animateBoxes( $('.npoWrap'), $(this), 'right');
    });

    $('#usersButton').click( function() {
        if ( current.attr('id') == 'nposButton' )
            animateBoxes( $('.userWrap'), $(this), 'left');
        else
            animateBoxes( $('.userWrap'), $(this), 'right');
    });

    $('#busButton').click( function() {
        animateBoxes( $('.businessWrap'), $(this), 'left');
    });

    function animateBoxes( inWrap, button, direction ) {
        if ( current.attr('id') != button.attr('id') ) {

            var dir = 1;

            if ( direction == 'right' )
                dir = -1;

            inWrap.css('left', dir*currentWrap.width());
            inWrap.show();

            current.removeClass('chosen');
            button.addClass('chosen');

            inWrap.animate( {
                left: 0
            }, animationTime);
            currentWrap.animate( {
                left: -1*dir*currentWrap.width()
            }, animationTime);

            currentWrap = inWrap;
            current = button;
        }
    }
}

function loadField(field, value) {
    var fi = $('#'+field);
    fi.val(value);

    fi.bind({

        focusin: function() {
            if ( $(this).val() == value)
                $(this).val("");
        },

        focusout: function() {

            if ( $(this).val() == '') {

                $(this).css("color", "#777");
                $(this).val(value);
            }

            else {
                $(this).css("color", "#222");
            }
        }
    });
}

function loadPasswordField(field, value) {
    var fi = $('#'+field);

    fi.bind({

        focusin: function() {
            $('.npoPassSpan').hide();
        },

        focusout: function() {

            if ( $(this).val() == '') {

                $(this).css("color", "#777");
                $('.npoPassSpan').show();
            }

            else {
                $(this).css("color", "#222");
            }
        }
    });

    $('.npoPassSpan').click( function() {
        fi.focus();
    });

}
