var con;

function send(cmd,a,b){
    var bs=typeof(b)=="undefined"?0:b;
    var o={cmd:cmd,a:parseInt(a),b:parseInt(bs)}
    con.send(JSON.stringify(o));
}
function kcdwn(kc){ send("kcdwn",kc); }
function kcup(kc){ send("kcup",kc); }
function mv(x,y){ send("ptrmv",x,y) }
function click(ind,dir) { send("ptrbtn",ind,dir) }

function init(){
    con=new WebSocket("ws://localhost:10000");

    window.onkeydown=function(e){ kcdwn(e.keyCode) }
    window.onkeyup=function(e){ kcup(e.keyCode) }
    
    var s=document.getElementById("screen")

    s.onmousemove=function(e){ mv(e.clientX,e.clientY) }
    s.onmousedown=function(e){ click(0,1) } 
    s.onmouseup=function(e){ click(0,0) } 
}

if(document.readyState=="complete" || (document.readyState!="loading" && document.documentElement.doScroll)) init();
else document.addEventListener("DOMContentLoaded",init);
