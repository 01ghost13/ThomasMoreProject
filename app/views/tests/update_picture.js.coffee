$("#description_id").html("<p><%= j(@description) %></p>");
valeur = "<%= j(@progress_bar_value.to_s) %>";
$("#bar_id").css('width', valeur+'%').attr('aria-valuenow', valeur);
url = window.location.protocol+'//'+window.location.host
$("#cur_image").attr('src',url+"<%= j("/assets/"+@image.to_s) %>");
$("#cur_image").attr('alt',"<%= j(@image) %>");
$("#btn_back").attr('disabled',"<%= j(!@show_btn_back)%>");
