(function(){$(window).on("beforeunload",function(){$.ajax({url:"testing/exit",type:"Post",async:!1,beforeSend:function(e){return e.setRequestHeader("X-CSRF-Token",$('meta[name="csrf-token"]').attr("content"))}})})}).call(this);