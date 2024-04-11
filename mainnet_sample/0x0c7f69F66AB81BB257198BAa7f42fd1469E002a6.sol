// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;


// 
pragma solidity >=0.7.6;


interface OutboundChannel {
    function submit(address origin, bytes calldata payload) external;
}
// 
pragma solidity >=0.7.6;




// BasicOutboundChannel is a basic channel that just sends messages with a nonce.
contract BasicOutboundChannel is OutboundChannel {

    uint64 public nonce;

    event Message(
        address source,
        uint64 nonce,
        bytes payload
    );

    /**
     * @dev Sends a message across the channel
     */
    function submit(address, bytes calldata payload) external override {
        nonce = nonce + 1;
        emit Message(msg.sender, nonce, payload);
    }
}
