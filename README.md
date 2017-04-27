# PeerClientApp

## About
<b>PeerClientApp</b> is WebRTC client application for iOS which demonstrates how to use PeerClient framework. This application shows how to create native WebRTC client with Swift. You can call to other peer with video and also send data with data connection. You can draw particles by swiping video screen area which is also shown in the other side of peer's screen during the call. 


## Dependencies

### [PeerClient](https://github.com/akiramur/PeerClient)  
### [SocketRocket](https://github.com/facebook/SocketRocket)  
### [peerjs-server](https://github.com/peers/peerjs-server)  



## Usage

1. Clone [PeerClient](https://github.com/akiramur/PeerClient) repository

```
$ git clone https://github.com/akiramur/PeerClient.git
```

2. Clone this repository.

```
$ git clone https://github.com/akiramur/PeerClientApp.git
```

3. Download [SocketRocket](https://github.com/facebook/SocketRocket) with carthage  

```
% cd path_to_the_directory/PeerClientApp  
% carthage update --platform iOS  
```

4. You also need existing [peerjs-server](https://github.com/peers/peerjs-server) which is already up and runing for signailng, or you need to set up by yourself.

## License

MIT

