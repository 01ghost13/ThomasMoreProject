id = <%= @id %>
$(id).parent().parent().parent().find("div#image").
html("<%= j(image_tag @picture.image.url :thumb, class: 'col-sm-2') %>")