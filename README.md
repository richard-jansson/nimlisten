# Nimlisten 

The purpose of nimlisten is to provide a client program control over OS resources, such as keyboard presses and mouse input. It listens for commands formatted with JSON on a websocket connection. These are then relayed to via for example WinAPI to the operating system. The intent of the program is to serve as the receiver of commands from experimental input methods. The prototyping of those methods are for speed of development done with HTML + js. An additional benefit of creating prototypes with web technologies is that the same UI code that are used for desktop can be used to demonstrate the technology to users without requiring any software insallation. For those who want to tie the programs in to the os the websocket / JSON layer serves as glue between the OS and the browser, allowing access to functionalities otherwise unaccessible to the browser. 

## Choice of language 

As we are dealing with software that handles user interface, strict control over resource usage is of essence. On the other hand prototyping of user interfaces, in a setting where quick dramatic changes are supposed to be implemented quickly makes a low level language such as C or even C++ a bad fit. Furthermore the client code can make use of the readily available rendering engine in the webrowser, saving loads of time on implementing fonts for foreign languages etc. 

## Remote control desktop as a sideeffect

While not being the stated goal of the project, I realized that the program can be retrofitted to do a traditional remote desktop control. This also serves as a testing ground for the underlying protocol. Which today is very primitive. By starting the nim program and opening the remote.html this functionality can be tested. 

## libmjpeg 

The program facilitates mjpeg streaming with made from scratch http support. Incidentally a subset of the websocket protocol is also made from scratch in C. Whereas it would be possible to use windows API to compress JPEG images, with platform independence in mind a subset of libjpeg has been made accessible to nim. A better approach would be to make use of syntax tree analysis and nim interop to make calls to jpeg. However interop is one or two patches away from being able to handle libmjpeg. The interfacing has as such been done as an excersie in foreign function interfacing from nim.  

## Threads 
The underlying http and ws functionallity written in C, spawns new threads therefore some parameters needs to be sent to the nim program, namely: 

--threads:on --tlsEmulation:off

so that the functions below work as expected. These are necessery when a new thread has been spawned in the C functions and nim callbacks are run.  

system.setupForeignThreadGc()
system.tearDownForeignThreadGc()

## Architectue and further development 
Bear in mind that this is a very early version of the project. In short thought the http and websocket functions can listen on ports and hand over access to nim functions once a new client has connected.  

## No warranties 

This is a very early version of the program and is not meant for production usage in any shape or form. 
