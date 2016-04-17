$("#description_id").html("<p><%= j(@description) %></p>");
valeur = "<%= j(@progress_bar_value.to_s) %>";
$("#bar_id").css('width', valeur+'%').attr('aria-valuenow', valeur);
$("#cur_image").attr('src',"<%= j("http://localhost:3000/assets/"+@image.to_s) %>");
$("#cur_image").attr('alt',"<%= j(@image) %>");
