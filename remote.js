var con;

function send(cmd,code){
    var o={cmd:cmd,code:parseInt(code)}
   con.send(JSON.stringify(o));
}

function kcdwn(kc){ send("kcdwn",kc); }
function kcup(kc){ send("kcup",kc); }

function init(){
    con=new WebSocket("ws://localhost:10000");

    window.onkeydown=function(e){ kcdwn(e.keyCode) }
    window.onkeyup=function(e){ kcup(e.keyCode) }
}

if(document.readyState=="complete" || (document.readyState!="loading" && document.documentElement.doScroll)) init();
else document.addEventListener("DOMContentLoaded",init);
