# EchoServer

# Features:
When server start it begin listening specified TCP-port. After user connection server accepts it and than in the cycle makes next steps:
- read from socket received data;
- send back unchanged data.

Сycle continues until the client disconnects or until receives comand "disconnect\n".
Received the command "disconnect\n" server closes the client socket.

# Instructions:
- run program
- in terminal: $ telnet localhost "your port"
- Enter any message
- Be happy 😺
