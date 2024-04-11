 
pragma experimental ABIEncoderV2;


 
pragma solidity >=0.7.6;


interface OutboundChannel {
    function submit(address origin, bytes calldata payload) external;
}
 
pragma solidity >=0.7.6;




 
contract BasicOutboundChannel is OutboundChannel {

    uint64 public nonce;

    event Message(
        address source,
        uint64 nonce,
        bytes payload
    );

     
    function submit(address, bytes calldata payload) external override {
        nonce = nonce + 1;
        emit Message(msg.sender, nonce, payload);
    }
}
