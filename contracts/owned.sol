// DO NOT use the newest version of solidity but an old stable one, check the bug lists of in the release anouncement of solidity after this versions.
pragma solidity ^0.4.8;

contract owned {
    address owner;

    modifier onlyowner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function owned() {
        owner = msg.sender;
    }
}
