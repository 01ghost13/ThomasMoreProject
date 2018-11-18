// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require Chart.bundle
//= require chartkick
//= require react
//= require react_ujs
//= require activestorage
//= require components
//= require lodash

//Converts all text in class "date_to_local" to local time
$(document).on('turbolinks:load', function () {
    $('.date_to_local').each(function () {
        var date = new Date($(this).text());
        $(this).text(date.toLocaleString())
    })
});