$("#description_id").html("<p><%= j(@description) %></p>");
valeur = "<%= j(@progress_bar_value.to_s) %>";
$("#bar_id").css('width', valeur+'%').attr('aria-valuenow', valeur);
$("#cur_image").attr('src',"<%= j(image_url @image) %>");
$("#cur_image").attr('alt',"<%= j(@image) %>");
$("#btn_back").attr('disabled',"<%= j(!@show_btn_back)%>");
